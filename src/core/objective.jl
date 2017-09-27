function objective_min_redispatch_cost(pm::GenericPowerModel, nws=[pm.cnw])
    PowerModels.check_cost_models(pm, nws)


    # pg = Dict(n => pm.var[:nw][n][:pg] for n in nws)
    # dc_p = Dict(n => pm.var[:nw][n][:p_dc] for n in nws)

    # # from_idx = Dict()
    # for n in nws
    #     ref = pm.ref[:nw][n]
    #     from_idx[n] = Dict(arc[1] => arc for arc in ref[:arcs_from_dc])
    # end

    pg_delta = PowerModels.var(pm, :pg_delta)
    pl_delta = PowerModels.var(pm, :pl_delta)

    return @objective(pm.model, Min,
        sum(gen["cost"][1]*pg_delta[i]^2 + gen["cost"][2]*pg_delta[i] for (i,gen) in PowerModels.ref(pm,:gen)) +
        sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, :load))
    )
end

function objective_total_risk(pm::GenericPowerModel, first_stage_network_id, second_stage_network_ids)
    first_stage_cost = constraint_first_stage_cost(pm::GenericPowerModel, first_stage_network_id)
    second_stage_risk = constraint_second_stage_risk(pm::GenericPowerModel, second_stage_network_ids)
    return @objective(pm.model, Min, first_stage_cost + second_stage_risk)
end


function constraint_first_stage_cost(pm::GenericPowerModel, first_stage_network_id)
    pg_delta = PowerModels.var(pm, first_stage_network_id, :pg_delta)
    pl_delta = PowerModels.var(pm, first_stage_network_id, :pl_delta)

    return first_stage_cost =
        sum(gen["cost"][1]*pg_delta[i]^2 + gen["cost"][2]*pg_delta[i] for (i,gen) in PowerModels.ref(pm,:gen)) +
        sum(load["voll"]*pl_delta[i] for (i,load) in PowerModels.ref(pm, :load));
end

function constraint_second_stage_risk(pm::GenericPowerModel, second_stage_network_ids)

    pg_delta = Dict(n => pm.var[:nw][n][:pg_delta] for (n, contingency_id) in second_stage_network_ids)
    pl_delta = Dict(n => pm.var[:nw][n][:pl_delta] for (n, contingency_id) in second_stage_network_ids)

    return second_stage_risk =
    sum(    pm.ref[:nw][n][:contingencies][contingency_id]["prob"] *
            (
            sum(gen["cost"][1]*pg_delta[n][i]^2 + gen["cost"][2]*pg_delta[n][i] + gen["cost"][3] for (i,gen) in pm.ref[:nw][n][:gen]) +
            sum(load["voll"]*pl_delta[n][i] for (i,load) in pm.ref[:nw][n][:load])
            )
            for (n, contingency_id) in second_stage_network_ids
    );
end
