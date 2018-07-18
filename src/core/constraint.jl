function constraint_active_load_gen_aggregation(pm::GenericPowerModel, n::Int, i::Int, bus_gens, pd)
    pnode = PowerModels.var(pm, n, :pnode)[i]
    pg = PowerModels.var(pm, n, :pg)

    @constraint(pm.model, pnode == sum(pg[g] for g in bus_gens) - pd)
end

function constraint_reactive_load_gen_aggregation(pm::GenericPowerModel, n::Int, i::Int, bus_gens, qd)
    qnode = PowerModels.var(pm, n, :qnode)[i]
    qg = PowerModels.var(pm, n, :qg)

    @constraint(pm.model, qnode == sum(qg[g] for g in bus_gens) - qd)
end

""
function constraint_active_load_gen_aggregation_sheddable(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, bus_gens, bus_loads)
    pnode = PowerModels.var(pm, n, cnd, :pnode, i)
    pg = PowerModels.var(pm, n, cnd, :pg)
    pl = PowerModels.var(pm, n, cnd, :pl)

    @constraint(pm.model, pnode == sum(pg[g] for g in bus_gens) - sum(pl[l] for l in bus_loads))
end

function constraint_reactive_load_gen_aggregation_sheddable(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, bus_gens, bus_loads)
    qnode = PowerModels.var(pm, n, cnd, :qnode, i)
    qg = PowerModels.var(pm, n, cnd, :qg)
    ql = PowerModels.var(pm, n, cnd, :ql)

    @constraint(pm.model, qnode == sum(qg[g] for g in bus_gens) - sum(ql[l] for l in bus_loads))
end

""
function constraint_flexible_active_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, prated, pref)
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta, i)
    load_ind = PowerModels.var(pm, n, cnd, :load_ind, i)

    @constraint(pm.model,   pl_delta <= 2 * prated * load_ind)
end

function constraint_flexible_reactive_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, qrated, qref)
    ql_delta = PowerModels.var(pm, n, cnd, :ql_delta, i)
    load_ind = PowerModels.var(pm, n, cnd, :load_ind, i)

    @constraint(pm.model,   ql_delta <= 2 * qrated * load_ind)
end
# function constraint_flexible_active_load(pm::GenericPowerModel, n::Int, i::Int, prated, pref)
#     pl_delta = PowerModels.var(pm, n, :pl_delta)[i]
#     load_ind = PowerModels.var(pm, n, :load_ind)[i]
#
#     @constraint(pm.model,   pl_delta <= 2 * prated * load_ind)
# end
#
# function constraint_flexible_reactive_load(pm::GenericPowerModel, n::Int, i::Int, qrated, qref)
#     ql_delta = PowerModels.var(pm, n, :ql_delta)[i]
#     load_ind = PowerModels.var(pm, n, :load_ind)[i]
#
#     @constraint(pm.model,   ql_delta <= 2 * qrated * load_ind)
# end

""
function constraint_fixed_active_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, pref::AbstractFloat)
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta, i)
    pl = PowerModels.var(pm, n, cnd, :pl, i)

    @constraint(pm.model, pl_delta == 0)
    @constraint(pm.model, pl == pref)
end

function constraint_fixed_reactive_load(pm::GenericPowerModel, n::Int,  cnd::Int, i::Int, qref::AbstractFloat)
    ql_delta = PowerModels.var(pm, n, cnd, :ql_delta, i)
    ql = PowerModels.var(pm, n, cnd, :ql, i)

    @constraint(pm.model, ql_delta == 0)
    @constraint(pm.model, ql == qref)
end

# function constraint_fixed_active_load(pm::GenericPowerModel, n::Int, i::Int, pref::AbstractFloat)
#     pl_delta = PowerModels.var(pm, n, :pl_delta)[i]
#     pl = PowerModels.var(pm, n, :pl)[i]
#
#     @constraint(pm.model, pl_delta == 0)
#     @constraint(pm.model, pl == pref)
# end
#
# function constraint_fixed_reactive_load(pm::GenericPowerModel, n::Int, i::Int, qref::AbstractFloat)
#     ql_delta = PowerModels.var(pm, n, :ql_delta)[i]
#     ql = PowerModels.var(pm, n, :ql)[i]
#
#     @constraint(pm.model, ql_delta == 0)
#     @constraint(pm.model, ql == qref)
# end
""
function constraint_flexible_active_gen(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, prated, pref)
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    gen_ind = PowerModels.var(pm, n, cnd, :gen_ind, i)

    @constraint(pm.model,   pg_delta <= 2 * prated * gen_ind)
end

function constraint_flexible_reactive_gen(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, qrated, qref)
    qg_delta = PowerModels.var(pm, n, cnd, :qg_delta, i)
    gen_ind = PowerModels.var(pm, n, cnd, :gen_ind, i)

    @constraint(pm.model,   qg_delta <= 2 * qrated * gen_ind)
end
# function constraint_flexible_active_gen(pm::GenericPowerModel, n::Int, i::Int, prated, pref)
#     pg_delta = PowerModels.var(pm, n, :pg_delta)[i]
#     gen_ind = PowerModels.var(pm, n, :gen_ind)[i]
#
#     @constraint(pm.model,   pg_delta <= 2 * prated * gen_ind)
# end
#
# function constraint_flexible_reactive_gen(pm::GenericPowerModel, n::Int, i::Int, qrated, qref)
#     qg_delta = PowerModels.var(pm, n, :qg_delta)[i]
#     gen_ind = PowerModels.var(pm, n, :gen_ind)[i]
#
#     @constraint(pm.model,   qg_delta <= 2 * qrated * gen_ind)
# end
""
function constraint_redispatch_active_power_gen(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, pref::AbstractFloat)
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)

    @constraint(pm.model, pg_delta >= pg - pref)
    @constraint(pm.model, pg_delta >= -(pg - pref))
end

function constraint_redispatch_reactive_power_gen(pm::GenericPowerModel, n::Int,  cnd::Int, i::Int, qref::AbstractFloat)
    qg_delta = PowerModels.var(pm, n, cnd, :qg_delta, i)
    qg = PowerModels.var(pm, n, cnd, :qg, i)

    @constraint(pm.model, qg_delta >= qg - qref)
    @constraint(pm.model, qg_delta >= -(qg - qref))
end
# function constraint_redispatch_active_power_gen(pm::GenericPowerModel, n::Int, i::Int, pref::AbstractFloat)
#     pg_delta = PowerModels.var(pm, n, :pg_delta)[i]
#     pg = PowerModels.var(pm, n, :pg)[i]
#
#     @constraint(pm.model, pg_delta >= pg - pref)
#     @constraint(pm.model, pg_delta >= -(pg - pref))
# end
#
# function constraint_redispatch_reactive_power_gen(pm::GenericPowerModel, n::Int, i::Int, qref::AbstractFloat)
#     qg_delta = PowerModels.var(pm, n, :qg_delta)[i]
#     qg = PowerModels.var(pm, n, :qg)[i]
#
#     @constraint(pm.model, qg_delta >= qg - qref)
#     @constraint(pm.model, qg_delta >= -(qg - qref))
# end
""
function constraint_second_stage_redispatch_active_power_gen(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, first_stage_network_id)
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)
    pg_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :pg, i)

    @constraint(pm.model, pg_delta >= pg - pg_first_stage)
    @constraint(pm.model, pg_delta >= -(pg - pg_first_stage))
end

function constraint_second_stage_redispatch_reactive_power_gen(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, first_stage_network_id)
    qg_delta = PowerModels.var(pm, n, cnd, :qg_delta, i)
    qg = PowerModels.var(pm, n, cnd, :qg, i)
    qg_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :qg, i)

    @constraint(pm.model, qg_delta >= qg - qg_first_stage)
    @constraint(pm.model, qg_delta >= -(qg - qg_first_stage))
end
# function constraint_second_stage_redispatch_active_power_gen(pm::GenericPowerModel, n::Int, i::Int, first_stage_network_id)
#     pg_delta = PowerModels.var(pm, n, :pg_delta)[i]
#     pg = PowerModels.var(pm, n, :pg)[i]
#     pg_first_stage = PowerModels.var(pm, first_stage_network_id, :pg)[i]
#
#     @constraint(pm.model, pg_delta >= pg - pg_first_stage)
#     @constraint(pm.model, pg_delta >= -(pg - pg_first_stage))
# end
#
# function constraint_second_stage_redispatch_reactive_power_gen(pm::GenericPowerModel, n::Int, i::Int, first_stage_network_id)
#     qg_delta = PowerModels.var(pm, n, :qg_delta)[i]
#     qg = PowerModels.var(pm, n, :qg)[i]
#     qg_first_stage = PowerModels.var(pm, first_stage_network_id, :qg)[i]
#
#     @constraint(pm.model, qg_delta >= qg - qg_first_stage)
#     @constraint(pm.model, qg_delta >= -(qg - qg_first_stage))
# end
""
function constraint_redispatch_active_power_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, pref::AbstractFloat)
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta, i)
    pl = PowerModels.var(pm, n, cnd, :pl, i)

    @constraint(pm.model, pl_delta >= pl - pref)
    @constraint(pm.model, pl_delta >= -(pl - pref))
end

function constraint_redispatch_reactive_power_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, qref::AbstractFloat)
    ql_delta = PowerModels.var(pm, n, cnd, :ql_delta, i)
    ql = PowerModels.var(pm, n, cnd, :ql, i)

    @constraint(pm.model, ql_delta >= ql - qref)
    @constraint(pm.model, ql_delta >= -(ql - qref))
end
# function constraint_redispatch_active_power_load(pm::GenericPowerModel, n::Int, i::Int, pref::AbstractFloat)
#     pl_delta = PowerModels.var(pm, n, :pl_delta)[i]
#     pl = PowerModels.var(pm, n, :pl)[i]
#
#     @constraint(pm.model, pl_delta >= pl - pref)
#     @constraint(pm.model, pl_delta >= -(pl - pref))
# end
#
# function constraint_redispatch_reactive_power_load(pm::GenericPowerModel, n::Int, i::Int, qref::AbstractFloat)
#     ql_delta = PowerModels.var(pm, n, :ql_delta)[i]
#     ql = PowerModels.var(pm, n, :ql)[i]
#
#     @constraint(pm.model, ql_delta >= ql - qref)
#     @constraint(pm.model, ql_delta >= -(ql - qref))
# end

""
function constraint_second_stage_redispatch_active_power_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, first_stage_network_id)
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta, i)
    pl = PowerModels.var(pm, n, cnd, :pl, i)
    pl_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :pl, i)

    @constraint(pm.model, pl_delta >= pl - pl_first_stage)
    @constraint(pm.model, pl_delta >= -(pl - pl_first_stage))
end

function constraint_second_stage_redispatch_reactive_power_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, first_stage_network_id)
    ql_delta = PowerModels.var(pm, n, cnd, :ql_delta, i)
    ql = PowerModels.var(pm, n, cnd, :ql, i)
    ql_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :ql, i)

    @constraint(pm.model, ql_delta >= ql - ql_first_stage)
    @constraint(pm.model, ql_delta >= -(ql - ql_first_stage))
end
# function constraint_second_stage_redispatch_active_power_load(pm::GenericPowerModel, n::Int, i::Int, first_stage_network_id)
#     pl_delta = PowerModels.var(pm, n, :pl_delta)[i]
#     pl = PowerModels.var(pm, n, :pl)[i]
#     pl_first_stage = PowerModels.var(pm, first_stage_network_id, :pl)[i]
#
#     @constraint(pm.model, pl_delta >= pl - pl_first_stage)
#     @constraint(pm.model, pl_delta >= -(pl - pl_first_stage))
# end
#
# function constraint_second_stage_redispatch_reactive_power_load(pm::GenericPowerModel, n::Int, i::Int, first_stage_network_id)
#     ql_delta = PowerModels.var(pm, n, :ql_delta)[i]
#     ql = PowerModels.var(pm, n, :ql)[i]
#     ql_first_stage = PowerModels.var(pm, first_stage_network_id, :ql)[i]
#
#     @constraint(pm.model, ql_delta >= ql - ql_first_stage)
#     @constraint(pm.model, ql_delta >= -(ql - ql_first_stage))
# end

"""
Q = P * tan(load_angle): To avoid division by 0: Q*cos(load_angle) = P*sin(load_angle)
"""
function constraint_tan_phi_load(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, load_angle)
    ql = PowerModels.var(pm, n, cnd, :ql, i)
    pl = PowerModels.var(pm, n, cnd, :pl, i)

    @constraint(pm.model, ql * cos(load_angle) == pl * sin(load_angle))
end
# function constraint_tan_phi_load(pm::GenericPowerModel, n::Int, i::Int, load_angle)
#     ql = PowerModels.var(pm, n, :ql)[i]
#     pl = PowerModels.var(pm, n, :pl)[i]
#
#     @constraint(pm.model, ql * cos(load_angle) == pl * sin(load_angle))
# end

""
function constraint_active_power_gen_contingency(pm::GenericPowerModel, n::Int, cnd::Int, i::Int)
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)

    @constraint(pm.model, pg_delta == 0)
    @constraint(pm.model, pg == 0)
end

function constraint_reactive_power_gen_contingency(pm::GenericPowerModel, n::Int, cnd::Int, i::Int)
    qg_delta = PowerModels.var(pm, n, cnd, :qg_delta, i)
    qg = PowerModels.var(pm, n, cnd, :qg, i)

    @constraint(pm.model, qg_delta == 0)
    @constraint(pm.model, qg == 0)
end
# function constraint_active_power_gen_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     pg_delta = PowerModels.var(pm, n, :pg_delta)[i]
#     pg = PowerModels.var(pm, n, :pg)[i]
#
#     @constraint(pm.model, pg_delta == 0)
#     @constraint(pm.model, pg == 0)
# end
#
# function constraint_reactive_power_gen_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     qg_delta = PowerModels.var(pm, n, :qg_delta)[i]
#     qg = PowerModels.var(pm, n, :qg)[i]
#
#     @constraint(pm.model, qg_delta == 0)
#     @constraint(pm.model, qg == 0)
# end

""
function constraint_active_power_branch_contingency(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, f_idx, t_idx)
    p_fr = PowerModels.var(pm, n, cnd, :p, f_idx)
    p_to = PowerModels.var(pm, n, cnd, :p, t_idx)
    va_shift_fr = PowerModels.var(pm, n, cnd, :va_shift, f_idx)
    va_shift_to = PowerModels.var(pm, n, cnd, :va_shift, t_idx)

    @constraint(pm.model, p_fr == 0)
    @constraint(pm.model, p_to == 0)
    @constraint(pm.model, va_shift_fr  == 0)
    @constraint(pm.model, va_shift_to  == 0)
end

function constraint_reactive_power_branch_contingency(pm::GenericPowerModel, n::Int, cnd::Int, i::Int, f_idx, t_idx)
    q_fr = PowerModels.var(pm, n, cnd, :q, f_idx)
    q_to = PowerModels.var(pm, n, cnd, :q, t_idx)
    vm_tap_fr = PowerModels.var(pm, n, cnd, :vm_tap, f_idx)
    vm_tap_to = PowerModels.var(pm, n, cnd, :vm_tap, t_idx)

    @constraint(pm.model, q_fr == 0)
    @constraint(pm.model, q_to == 0)
    @constraint(pm.model, vm_tap_fr  == 1)
    @constraint(pm.model, vm_tap_to  == 1)
end
# function constraint_active_power_branch_contingency(pm::GenericPowerModel, n::Int, i::Int, f_idx, t_idx)
#     p_fr = PowerModels.var(pm, n, :p)[f_idx]
#     p_to = PowerModels.var(pm, n, :p)[t_idx]
#     va_shift_fr = PowerModels.var(pm, n, :va_shift)[f_idx]
#     va_shift_to = PowerModels.var(pm, n, :va_shift)[t_idx]
#
#     @constraint(pm.model, p_fr == 0)
#     @constraint(pm.model, p_to == 0)
#     @constraint(pm.model, va_shift_fr  == 0)
#     @constraint(pm.model, va_shift_to  == 0)
# end
#
# function constraint_reactive_power_branch_contingency(pm::GenericPowerModel, n::Int, i::Int, f_idx, t_idx)
#     q_fr = PowerModels.var(pm, n, :q)[f_idx]
#     q_to = PowerModels.var(pm, n, :q)[t_idx]
#     vm_tap_fr = PowerModels.var(pm, n, :vm_tap)[f_idx]
#     vm_tap_to = PowerModels.var(pm, n, :vm_tap)[t_idx]
#
#     @constraint(pm.model, q_fr == 0)
#     @constraint(pm.model, q_to == 0)
#     @constraint(pm.model, vm_tap_fr  == 1)
#     @constraint(pm.model, vm_tap_to  == 1)
# end
