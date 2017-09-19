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
