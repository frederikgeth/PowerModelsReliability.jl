function objective_min_redispatch_cost(pm::GenericPowerModel)
    PowerModels.check_cost_models(pm)
    pg_delta = pm.var[:pg_delta]
    pl_delta = pm.var[:pl_delta]

    return @objective(pm.model, Min,
        sum(gen["cost"][1]*pg_delta[i]^2 + gen["cost"][2]*pg_delta[i] for (i,gen) in pm.ref[:gen]) +
        sum(load["voll"]*pl_delta[i] for (i,load) in pm.ref[:load])
    )
end
