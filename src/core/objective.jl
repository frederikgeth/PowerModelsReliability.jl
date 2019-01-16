function objective_min_redispatch_cost(pm::GenericPowerModel)
    PowerModels.check_cost_models(pm)

    return @objective(pm.model, Min,
        sum(
            sum(   gen["cost"][1]*sum( PowerModels.var(pm, n, c, :pg_delta, i) for c in PowerModels.conductor_ids(pm, n))^2 +
                   gen["cost"][2]*sum( PowerModels.var(pm, n, c, :pg_delta, i) for c in PowerModels.conductor_ids(pm, n))+
                   gen["cost"][3] for (i,gen) in nw_ref[:gen]) +
            sum(
                load["voll"]*sum( PowerModels.var(pm, n, c, :pl_delta, i) for c in PowerModels.conductor_ids(pm, n)) for (i,load) in PowerModels.ref(pm, :load))
        for (n, nw_ref) in PowerModels.nws(pm))
    )
end

function objective_total_risk(pm::GenericPowerModel, first_stage_network_id, second_stage_network_ids)
    constraint_first_stage_cost(pm::GenericPowerModel, first_stage_network_id)
    constraint_second_stage_risk(pm::GenericPowerModel, second_stage_network_ids)
    for (n, network) in pm.ref[:nw]
        constraint_dispatch_cost(pm::GenericPowerModel, n)
        constraint_redispatch_cost(pm::GenericPowerModel, n)
        constraint_loadshedding_cost(pm::GenericPowerModel, n)
    end
    first_stage_cost = PowerModels.var(pm, :first_stage_cost)
    second_stage_risk = PowerModels.var(pm, :second_stage_risk)

    return @objective(pm.model, Min, first_stage_cost + second_stage_risk)
end

function objective_total_risk(pm::GenericPowerModel{T}, first_stage_network_id, second_stage_network_ids; cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm

    for (n, network) in pm.ref[:nw]
        constraint_loadshedding_cost(pm::GenericPowerModel, n)
    end
    pg_delta = PowerModels.var(pm, first_stage_network_id, cnd, :pg_delta)
    pl_delta = PowerModels.var(pm, first_stage_network_id, cnd, :pl_delta)

    pg_delta_ss = Dict(n => PowerModels.var(pm, n, cnd, :pg_delta) for (n, contingency_id) in second_stage_network_ids)
    pl_delta_ss = Dict(n => PowerModels.var(pm, n, cnd, :pl_delta) for (n, contingency_id) in second_stage_network_ids)

    return @objective(pm.model, Min, sum(gen["cost"][1]*pg_delta[i]^2 + gen["cost"][2]*pg_delta[i] for (i,gen) in PowerModels.ref(pm, :gen)) +
    sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, :load)) + sum(    pm.ref[:nw][n][:contingencies][contingency_id]["prob"] *
            (
            sum(gen["cost"][1]*pg_delta_ss[n][i]^2 + gen["cost"][2]*pg_delta_ss[n][i] for (i,gen) in pm.ref[:nw][n][:gen]) +
            sum(load["voll"]*pl_delta_ss[n][i] for (i,load) in pm.ref[:nw][n][:load])
            )
            for (n, contingency_id) in second_stage_network_ids
    ))
end

function constraint_first_stage_cost(pm::GenericPowerModel, first_stage_network_id; cnd::Int = pm.ccnd)
    pg_delta = PowerModels.var(pm, first_stage_network_id, cnd, :pg_delta)
    pl_delta = PowerModels.var(pm, first_stage_network_id, cnd, :pl_delta)
    first_stage_cost = PowerModels.var(pm, :first_stage_cost)

    return  @constraint(pm.model, first_stage_cost ==
        sum(gen["cost"][1]*pg_delta[i]^2 + gen["cost"][2]*pg_delta[i] for (i,gen) in PowerModels.ref(pm, :gen)) +
        sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, :load)))
end

function constraint_second_stage_risk(pm::GenericPowerModel, second_stage_network_ids; cnd::Int = pm.ccnd)
    pg_delta = Dict(n => PowerModels.var(pm, n, cnd, :pg_delta) for (n, contingency_id) in second_stage_network_ids)
    pl_delta = Dict(n => PowerModels.var(pm, n, cnd, :pl_delta) for (n, contingency_id) in second_stage_network_ids)
    second_stage_risk = PowerModels.var(pm, :second_stage_risk)

    return @constraint(pm.model, second_stage_risk ==
    sum(    PowerModels.ref(pm, n, :contingencies, contingency_id)["prob"] *
            (
            sum(gen["cost"][1]*pg_delta[n][i]^2 + gen["cost"][2]*pg_delta[n][i] for (i,gen) in PowerModels.ref(pm, n, :gen)) +
            sum(load["voll"]*pl_delta[n][i] for (i,load) in PowerModels.ref(pm, n, :load))
            )
            for (n, contingency_id) in second_stage_network_ids
    ))
end

function constraint_dispatch_cost(pm::GenericPowerModel, n; cnd::Int = pm.ccnd)
    # PowerModels.check_polynomial_cost_models(pm)
    order = PowerModels.calc_max_cost_index(pm.data)-1

    if order == 1
        return _objective_min_polynomial_fuel_cost_linear(pm)
    elseif order == 2
        return _objective_min_polynomial_fuel_cost_quadratic(pm)
    else
        error("cost model order of $(order) is not supported")
    end
end

function _objective_min_polynomial_fuel_cost_linear(pm::GenericPowerModel)
    from_idx = Dict()
    for (n, nw_ref) in nws(pm)
        from_idx[n] = Dict(arc[1] => arc for arc in nw_ref[:arcs_from_dc])
    end

    return @objective(pm.model, Min,
        sum(
            sum(   gen["cost"][1]*sum( var(pm, n, c, :pg, i) for c in conductor_ids(pm, n))+
                   gen["cost"][2] for (i,gen) in nw_ref[:gen])
        for (n, nw_ref) in nws(pm))
    )
end
""
function _objective_min_polynomial_fuel_cost_quadratic(pm::GenericPowerModel)
    from_idx = Dict()
    for (n, nw_ref) in nws(pm)
        from_idx[n] = Dict(arc[1] => arc for arc in nw_ref[:arcs_from_dc])
    end

    return @objective(pm.model, Min,
        sum(
            sum(   gen["cost"][1]*sum( var(pm, n, c, :pg, i) for c in conductor_ids(pm, n))^2 +
                   gen["cost"][2]*sum( var(pm, n, c, :pg, i) for c in conductor_ids(pm, n))+
                   gen["cost"][3] for (i,gen) in nw_ref[:gen])
        for (n, nw_ref) in nws(pm))
    )
end

function constraint_redispatch_cost(pm::GenericPowerModel, n; cnd::Int = pm.ccnd)
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta)
    redispatch_cost = PowerModels.var(pm, :redispatch_cost)

    return @constraint(pm.model, redispatch_cost[n] ==
            sum(gen["cost"][1]*pg_delta[i]^2 + gen["cost"][2]*pg_delta[i] for (i,gen) in PowerModels.ref(pm, n, :gen))
    )
end

function constraint_loadshedding_cost(pm::GenericPowerModel, n; cnd::Int = pm.ccnd)
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta)
    loadshedding_cost = PowerModels.var(pm, :loadshedding_cost)

    return @constraint(pm.model, loadshedding_cost[n] ==
            sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, n,:load))
    )
end
