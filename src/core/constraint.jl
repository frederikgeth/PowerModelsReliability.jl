function contraint_active_load_gen_aggregation(pm::GenericPowerModel, i::Int, bus_gens, pd)
    pnode = PowerModels.var(pm, :pnode)[i]
    pg = PowerModels.var(pm, :pg)

    @constraint(pm.model, pnode == sum(pg[g] for g in bus_gens) - pd)
end

function contraint_reactive_load_gen_aggregation(pm::GenericPowerModel, i::Int, bus_gens, qd)
    qnode = PowerModels.var(pm, :qnode)[i]
    qg = PowerModels.var(pm, :qg)

    @constraint(pm.model, qnode == sum(qg[g] for g in bus_gens) - qd)
end

""
function contraint_active_load_gen_aggregation_sheddable(pm::GenericPowerModel, i::Int, bus_gens, bus_loads)
    pnode = PowerModels.var(pm, :pnode)[i]
    pg = PowerModels.var(pm, :pg)
    pl = PowerModels.var(pm, :pl)

    @constraint(pm.model, pnode == sum(pg[g] for g in bus_gens) - sum(pl[l] for l in bus_loads))
end

function contraint_reactive_load_gen_aggregation_sheddable(pm::GenericPowerModel, i::Int, bus_gens, bus_loads)
    qnode = PowerModels.var(pm, :qnode)[i]
    qg = PowerModels.var(pm, :qg)
    ql = PowerModels.var(pm, :ql)

    @constraint(pm.model, qnode == sum(qg[g] for g in bus_gens) - sum(ql[l] for l in bus_loads))
end

""
function constraint_flexible_active_load(pm::GenericPowerModel, i::Int, prated, pref)
    pl_delta = PowerModels.var(pm, :pl_delta)[i]
    load_ind = PowerModels.var(pm, :load_ind)[i]

    @constraint(pm.model,   pl_delta <= 2 * prated * load_ind)
end

function constraint_flexible_reactive_load(pm::GenericPowerModel, i::Int, qrated, qref)
    ql_delta = PowerModels.var(pm, :ql_delta)[i]
    load_ind = PowerModels.var(pm, :load_ind)[i]

    @constraint(pm.model,   ql_delta <= 2 * qrated * load_ind)
end

function constraint_flexible_active_gen(pm::GenericPowerModel, i::Int, prated, pref)
    pg_delta = PowerModels.var(pm, :pg_delta)[i]
    gen_ind = PowerModels.var(pm, :gen_ind)[i]

    @constraint(pm.model,   pg_delta <= 2 * prated * gen_ind)
end

function constraint_flexible_reactive_gen(pm::GenericPowerModel, i::Int, qrated, qref)
    qg_delta = PowerModels.var(pm, :qg_delta)[i]
    gen_ind = PowerModels.var(pm, :gen_ind)[i]

    @constraint(pm.model,   qg_delta <= 2 * qrated * gen_ind)
end


function constraint_redispatch_power_gen(pm::GenericPowerModel, i::Int, pref::AbstractFloat)
    pg_delta = PowerModels.var(pm, :pg_delta)[i]
    pg = PowerModels.var(pm, :pg)[i]

    @constraint(pm.model, pg_delta >= pg - pref)
    @constraint(pm.model, pg_delta >= -(pg - pref))
end

function constraint_redispatch_power_load(pm::GenericPowerModel, i::Int, pref::AbstractFloat)
    pl_delta = PowerModels.var(pm, :pl_delta)[i]
    pl = PowerModels.var(pm, :pl)[i]

    @constraint(pm.model, pl_delta >= pl - pref)
    @constraint(pm.model, pl_delta >= -(pl - pref))
end
