function objective_min_redispatch_cost(pm::GenericPowerModel)
    PowerModels.check_cost_models(pm)

    gen_cost = Dict()
    for (n, nw_ref) in nws(pm)
        for (i,gen) in nw_ref[:gen]
            pg_delta = sum( var(pm, n, c, :pg_delta, i) for c in conductor_ids(pm, n) )
            if length(gen["cost"]) == 1
                gen_cost[(n,i)] = gen["cost"][1]
            elseif length(gen["cost"]) == 2
                gen_cost[(n,i)] = gen["cost"][1]*pg_delta + gen["cost"][2]
            elseif length(gen["cost"]) == 3
                gen_cost[(n,i)] = gen["cost"][1]*pg_delta^2 + gen["cost"][2]*pg_delta + gen["cost"][3]
            else
                gen_cost[(n,i)] = 0.0
            end
        end
    end
    return @objective(pm.model, Min,
        sum(
            sum( gen_cost[(n,i)] for (i,gen) in nw_ref[:gen] ) +
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

    gen_cost_fs = Dict()
    gen_cost_ss = Dict()
    for n in first_stage_network_id
        for (i,gen) in pm.ref[:nw][n][:gen]
            pg_fs = sum( var(pm, n, c, :pg_delta, i) for c in conductor_ids(pm, n) )
            if length(gen["cost"]) == 1
                gen_cost_fs[(i)] = 0
            elseif length(gen["cost"]) == 2
                gen_cost_fs[(i)] = gen["cost"][1]*pg_fs
            elseif length(gen["cost"]) == 3
                gen_cost_fs[(i)] = gen["cost"][2]*pg_fs
            else
                gen_cost_fs[(i)] = 0.0
            end
        end
    end
    for (cont_id, n) in second_stage_network_ids
        for (i,gen) in pm.ref[:nw][n][:gen]
            pg_ss = sum( var(pm, n, c, :pg_delta, i) for c in conductor_ids(pm, n) )
            if length(gen["cost"]) == 1
                gen_cost_ss[(n,i)] = 0
            elseif length(gen["cost"]) == 2
                gen_cost_ss[(n,i)] = gen["cost"][1]*pg_ss
            elseif length(gen["cost"]) == 3
                gen_cost_ss[(n,i)] = gen["cost"][2]*pg_ss
            else
                gen_cost_ss[(n,i)] = 0.0
            end
        end
    end

    return @objective(pm.model, Min,
            sum(gen_cost_fs[(i)] for (i,gen) in PowerModels.ref(pm, :gen)) +
            sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, :load)) +
            sum(    pm.ref[:nw][n][:contingencies][contingency_id]["prob"] *
            (
            sum(gen_cost_ss[(n,i)] for (i,gen) in pm.ref[:nw][n][:gen]) +
            sum(load["voll"]*pl_delta_ss[n][i] for (i,load) in pm.ref[:nw][n][:load])
            )
            for (contingency_id, n) in second_stage_network_ids
    ))
end

function constraint_first_stage_cost(pm::GenericPowerModel, first_stage_network_id; cnd::Int = pm.ccnd)
    pg_delta = PowerModels.var(pm, first_stage_network_id, cnd, :pg_delta)
    pl_delta = PowerModels.var(pm, first_stage_network_id, cnd, :pl_delta)
    first_stage_cost = PowerModels.var(pm, :first_stage_cost)

    gen_cost_fs = Dict()
    n = first_stage_network_id
    for (i,gen) in pm.ref[:nw][n][:gen]
        pg_delta_fs = sum( var(pm, n, c, :pg_delta, i) for c in conductor_ids(pm, n) )
        if length(gen["cost"]) == 1
            gen_cost_fs[(n,i)] = 0
        elseif length(gen["cost"]) == 2
            gen_cost_fs[(n,i)] = gen["cost"][1]*pg_delta_fs + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost_fs[(n,i)] = gen["cost"][1]*pg_delta_fs^2 + gen["cost"][2]*pg_delta_fs + gen["cost"][3]
        else
            gen_cost_fs[(n,i)] = 0.0
        end
    end

    return  @constraint(pm.model, first_stage_cost ==
        sum(gen_cost_fs[(n,i)] for (i,gen) in PowerModels.ref(pm, :gen)) +
        sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, :load)))
end

function constraint_second_stage_risk(pm::GenericPowerModel, second_stage_network_ids; cnd::Int = pm.ccnd)
    pg_delta = Dict(n => PowerModels.var(pm, n, cnd, :pg_delta) for (n, contingency_id) in second_stage_network_ids)
    pl_delta = Dict(n => PowerModels.var(pm, n, cnd, :pl_delta) for (n, contingency_id) in second_stage_network_ids)
    second_stage_risk = PowerModels.var(pm, :second_stage_risk)

    gen_cost_ss = Dict()
    for (cont_id, n)  in second_stage_network_ids
        for (i, gen) in pm.ref[:nw][n][:gen]
            pg_delta_ss = sum( var(pm, n, c, :pg_delta, i) for c in conductor_ids(pm, n) )
            if length(gen["cost"]) == 1
                gen_cost_ss[(n,i)] = 0
            elseif length(gen["cost"]) == 2
                gen_cost_ss[(n,i)] = gen["cost"][1]*pg_delta_ss + gen["cost"][2]
            elseif length(gen["cost"]) == 3
                gen_cost_ss[(n,i)] = gen["cost"][1]*pg_delta_ss^2 + gen["cost"][2]*pg_delta_ss + gen["cost"][3]
            else
                gen_cost_ss[(n,i)] = 0.0
            end
        end
    end
    return @constraint(pm.model, second_stage_risk ==
    sum(    PowerModels.ref(pm, n, :contingencies, cont_id)["prob"] *
            (
            sum(gen_cost_ss[(n,i)] for (i,gen) in PowerModels.ref(pm, n, :gen))  +
            sum(load["voll"]*pl_delta[n][i] for (i,load) in PowerModels.ref(pm, n, :load))
            )
            for (cont_id, n)  in second_stage_network_ids
    ))
end
""
function constraint_dispatch_cost(pm::GenericPowerModel, n; cnd::Int = pm.ccnd)
    gen_cost = Dict()
    dispatch_cost = PowerModels.var(pm, :dispatch_cost)
    for (i,gen) in pm.ref[:nw][n][:gen]
        pg = sum( var(pm, n, c, :pg, i) for c in conductor_ids(pm, n) )
        if length(gen["cost"]) == 1
            gen_cost[(i)] = gen["cost"][1]
        elseif length(gen["cost"]) == 2
            gen_cost[(i)] = gen["cost"][1]*pg + gen["cost"][2]
        elseif length(gen["cost"]) == 3
            gen_cost[(i)] = gen["cost"][1]*pg^2 + gen["cost"][2]*pg + gen["cost"][3]
        else
            gen_cost[(i)] = 0.0
        end
    end
    return @constraint(pm.model, dispatch_cost[n] ==
            sum( gen_cost[(i)] for (i,gen) in pm.ref[:nw][n][:gen] )
    )
end

function constraint_redispatch_cost(pm::GenericPowerModel, n; cnd::Int = pm.ccnd)
    redispatch_cost = PowerModels.var(pm, :redispatch_cost)
    gen_cost = Dict()

    for (i,gen) in pm.ref[:nw][n][:gen]
        pg_delta = sum( var(pm, n, c, :pg_delta, i) for c in conductor_ids(pm, n) )
        if length(gen["cost"]) == 1
            gen_cost[(i)] = 0
        elseif length(gen["cost"]) == 2
            gen_cost[(i)] = gen["cost"][1]*pg_delta
        elseif length(gen["cost"]) == 3
            gen_cost[(i)] = gen["cost"][1]*pg_delta^2 + gen["cost"][2]*pg_delta
        else
            gen_cost[(i)] = 0.0
        end
    end

    return @constraint(pm.model, redispatch_cost[n] ==
            sum( gen_cost[(i)] for (i,gen) in pm.ref[:nw][n][:gen] )
    )
end

function constraint_loadshedding_cost(pm::GenericPowerModel, n; cnd::Int = pm.ccnd)
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta)
    loadshedding_cost = PowerModels.var(pm, :loadshedding_cost)

    return @constraint(pm.model, loadshedding_cost[n] ==
            sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, n,:load))
    )
end
