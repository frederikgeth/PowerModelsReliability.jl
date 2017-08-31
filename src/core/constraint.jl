function contraint_active_load_gen_aggregation(pm::GenericPowerModel, i, bus_gens, pd)
    pnode = pm.var[:pnode][i]
    pg = pm.var[:pg]

    @constraint(pm.model, pnode == sum(pg[g] for g in bus_gens) - pd)
end

function contraint_reactive_load_gen_aggregation(pm::GenericPowerModel, i, bus_gens, qd)
    qnode = pm.var[:qnode][i]
    qg = pm.var[:qg]

    @constraint(pm.model, qnode == sum(qg[g] for g in bus_gens) - qd)
end

""
function contraint_active_load_gen_aggregation_sheddable(pm::GenericPowerModel, i, bus_gens, bus_loads)
    pnode = pm.var[:pnode][i]
    pg = pm.var[:pg]
    pl = pm.var[:pl]

    @constraint(pm.model, pnode == sum(pg[g] for g in bus_gens) - sum(pl[l] for l in bus_loads))
end

function contraint_reactive_load_gen_aggregation_sheddable(pm::GenericPowerModel, i, bus_gens, bus_loads)
    qnode = pm.var[:qnode][i]
    qg = pm.var[:qg]
    ql = pm.var[:ql]

    @constraint(pm.model, qnode == sum(qg[g] for g in bus_gens) - sum(ql[l] for l in bus_loads))
end

""
function constraint_flexible_active_load(pm::GenericPowerModel, i, prated, pref)
    pl_delta = pm.var[:pl_delta][i]
    load_ind = pm.var[:load_ind][i]

    @constraint(pm.model,   pl_delta <= 2 * prated * load_ind)
end

function constraint_flexible_reactive_load(pm::GenericPowerModel, i, qrated, qref)
    ql_delta = pm.var[:ql_delta][i]
    load_ind = pm.var[:load_ind][i]

    @constraint(pm.model,   ql_delta <= 2 * qrated * load_ind)
end

function constraint_flexible_active_gen(pm::GenericPowerModel, i, prated, pref)
    pg_delta = pm.var[:pg_delta][i]
    gen_ind = pm.var[:gen_ind][i]

    @constraint(pm.model,   pg_delta <= 2 * prated * gen_ind)
end

function constraint_flexible_reactive_gen(pm::GenericPowerModel, i, qrated, qref)
    qg_delta = pm.var[:qg_delta][i]
    gen_ind = pm.var[:gen_ind][i]

    @constraint(pm.model,   qg_delta <= 2 * qrated * gen_ind)
end


function constraint_redispatch_power_gen(pm::GenericPowerModel, i, pref)
    pg_delta = pm.var[:pg_delta][i]
    pg = pm.var[:pg][i]

    @constraint(pm.model, pg_delta >= pg - pref)
    @constraint(pm.model, pg_delta >= -(pg - pref))
end

function constraint_redispatch_power_load(pm::GenericPowerModel, i, pref)
    pl_delta = pm.var[:pl_delta][i]
    pl = pm.var[:pl][i]

    @constraint(pm.model, pl_delta >= pl - pref)
    @constraint(pm.model, pl_delta >= -(pl - pref))
end
