"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == g*vm_tap[f_idx]^2 + (-g)*(vm_tap[f_idx]*vm_tap[t_idx]*cos((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))) + (-b)*(vm_tap[f_idx]*vm_tap[t_idx]*sin((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))))
q[f_idx] == -(b+c/2)*vm_tap[f_idx]^2 - (-b)*(vm_tap[f_idx]*vm_tap[t_idx]*cos((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))) + (-g)*(vm_tap[f_idx]*vm_tap[t_idx]*sin((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))))
vm_tap[f_idx] * tap_min <= vm[f_bus] <= vm_tap[f_idx] * tap_max
```
"""
function constraint_variable_transformer_y_from(pm::GenericPowerModel{T}, n::Int, cnd::Int, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)  where T <: PowerModels.AbstractACPForm
    p_fr = PowerModels.var(pm, n, cnd, :p, f_idx)
    q_fr = PowerModels.var(pm, n, cnd, :q, f_idx)
    vm_fr = PowerModels.var(pm, n, cnd, :vm, f_bus)
    vm_to = PowerModels.var(pm, n, cnd, :vm, t_bus)
    va_fr = PowerModels.var(pm, n, cnd, :va, f_bus)
    va_to = PowerModels.var(pm, n, cnd, :va, t_bus)
    va_shift_fr = PowerModels.var(pm, n, cnd, :va_shift, f_idx)
    va_shift_to = PowerModels.var(pm, n, cnd, :va_shift, t_idx)
    vm_tap_fr = PowerModels.var(pm, n, cnd, :vm_tap, f_idx)
    vm_tap_to = PowerModels.var(pm, n, cnd, :vm_tap, t_idx)

    @NLconstraint(pm.model, p_fr == (g + g_shunt / 2)*vm_tap_fr^2 + (-g)*(vm_tap_fr*vm_tap_to*cos((va_fr - va_shift_fr) - (va_to - va_shift_to))) + (-b)*(vm_tap_fr*vm_tap_to*sin((va_fr - va_shift_fr) - (va_to - va_shift_to))))
    @NLconstraint(pm.model, q_fr == -(b+c/2)*vm_tap_fr^2 - (-b)*(vm_tap_fr*vm_tap_to*cos((va_fr - va_shift_fr) - (va_to - va_shift_to))) + (-g)*(vm_tap_fr*vm_tap_to*sin((va_fr - va_shift_fr) - (va_to - va_shift_to))))
    @constraint(pm.model, vm_tap_fr * tap_min <= vm_fr)
    @constraint(pm.model, vm_fr <= vm_tap_fr * tap_max)
end
"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[t_idx] == g*vm_tap[t_idx]^2 + (-g)*(vm_tap[t_idx]*vm_tap[f_idx]*cos((va[t_bus] - va_shift[t_idx]) - (va[f_bus] - va_shift[f_idx]))) + (-b)*(vm_tap[t_idx]*vm_tap[f_idx]*sin((va[t_bus] - va_shift[t_idx]) - (va[f_bus] - va_shift[f_idx]))))
q[t_idx] == -(b+c/2)*vm_tap[t_idx]^2 - (-b)*(vm_tap[t_idx]*vm_tap[f_idx]*cos((va[t_bus] - va_shift[t_idx]) - (va[f_bus] - va_shift[f_idx]))) + (-g)*(vm_tap[t_idx]*vm_tap[f_idx]*sin((va[t_bus] - va_shift[t_idx]) - (va[f_bus] - va_shift[f_idx]))))
vm_tap[t_idx] * tap_min <= vm[t_bus] <= vm_tap[t_idx] * tap_max
```
"""
function constraint_variable_transformer_y_to(pm::GenericPowerModel{T}, n::Int, cnd::Int, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max) where T <: PowerModels.AbstractACPForm
    p_to = PowerModels.var(pm, n, cnd :p, t_idx)
    q_to = PowerModels.var(pm, n, cnd, :q, t_idx)
    vm_fr = PowerModels.var(pm, n, cnd, :vm, f_bus)
    vm_to = PowerModels.var(pm, n, cnd, :vm, t_bus)
    va_fr = PowerModels.var(pm, n, cnd, :va, f_bus)
    va_to = PowerModels.var(pm, n, cnd, :va, t_bus)
    va_shift_fr = PowerModels.var(pm, n, cnd, :va_shift, f_idx)
    va_shift_to = PowerModels.var(pm, n, cnd, :va_shift, t_idx)
    vm_tap_fr = PowerModels.var(pm, n, cnd, :vm_tap, f_idx)
    vm_tap_to = PowerModels.var(pm, n, cnd, :vm_tap, t_idx)

    @NLconstraint(pm.model, p_to == (g + g_shunt / 2)*vm_tap_to^2 + (-g)*(vm_tap_to*vm_tap_fr*cos((va_to - va_shift_to) - (va_fr - va_shift_fr))) + (-b)*(vm_tap_to*vm_tap_fr*sin((va_to - va_shift_to) - (va_fr - va_shift_fr))))
    @NLconstraint(pm.model, q_to == -(b+c/2)*vm_tap_to^2 - (-b)*(vm_tap_to*vm_tap_fr*cos((va_to - va_shift_to) - (va_fr - va_shift_fr))) + (-g)*(vm_tap_to*vm_tap_fr*sin((va_to - va_shift_to) - (va_fr - va_shift_fr))))
    @constraint(pm.model, vm_tap_to * tap_min <= vm_to)
    @constraint(pm.model, vm_to <= vm_tap_to * tap_max)
end
"""
Links voltage magnitudes of not tappable transformers with node voltage magnitudes

```
vm_tap[f_idx] * tap == vm[f_bus]
vm_tap[t_idx] * tap == vm[t_bus]
```
"""
function constraint_link_voltage_magnitudes(pm::GenericPowerModel{T}, n::Int, cnd::Int, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to) where T <: PowerModels.AbstractACPForm
    vm_fr = PowerModels.var(pm, n, cnd, :vm, f_bus)
    vm_to = PowerModels.var(pm, n, cnd, :vm, t_bus)
    vm_tap_fr = PowerModels.var(pm, n, cnd, :vm_tap, f_idx)
    vm_tap_to = PowerModels.var(pm, n, cnd, :vm_tap, t_idx)
    @constraint(pm.model, vm_tap_fr * tap_fr == vm_fr)
    @constraint(pm.model, vm_tap_to * tap_to == vm_to)
end
"""
Aggregated unit representation in the nodes
```
sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == pnode - gs*v^2
sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == qnode + bs*v^2
```
"""
function constraint_kcl_shunt_aggregated(pm::GenericPowerModel{T}, n::Int, cnd::Int, i, bus_arcs, bus_arcs_dc, bus_gs, bus_bs) where T <: PowerModels.AbstractACPForm
    vm = PowerModels.var(pm, n, cnd, :vm, i)
    p = PowerModels.var(pm, n, cnd, :p)
    q = PowerModels.var(pm, n, cnd, :q)
    pnode = PowerModels.var(pm, n, cnd, :pnode, i)
    qnode = PowerModels.var(pm, n, cnd, :qnode, i)
    p_dc = PowerModels.var(pm, n, cnd, :p_dc)
    q_dc = PowerModels.var(pm, n, cnd, :q_dc)


    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == pnode - sum(gs for gs in values(bus_gs))*vm^2)
    @constraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == qnode + sum(bs for bs in values(bus_bs))*vm^2)
end
function constraint_redispatch_active_power_gen(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, pref::AbstractFloat) where T <: PowerModels.AbstractACPForm
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, pg_delta == abs(pg - pref))
    else
        @constraint(pm.model, pg_delta >= pg - pref)
        @constraint(pm.model, pg_delta >= -(pg - pref))
    end
end
function constraint_redispatch_reactive_power_gen(pm::GenericPowerModel{T}, n::Int,  cnd::Int, i::Int, qref::AbstractFloat) where T <: PowerModels.AbstractACPForm
    qg_delta = PowerModels.var(pm, n, cnd, :qg_delta, i)
    qg = PowerModels.var(pm, n, cnd, :qg, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, qg_delta == abs(qg - qref))
    else
        @constraint(pm.model, qg_delta >= qg - qref)
        @constraint(pm.model, qg_delta >= -(qg - qref))
    end
end
function constraint_second_stage_redispatch_active_power_gen(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, first_stage_network_id) where T <: PowerModels.AbstractACPForm
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)
    pg_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :pg, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, pg_delta == abs(pg - pg_first_stage))
    else
        @constraint(pm.model, pg_delta >= pg - pg_first_stage)
        @constraint(pm.model, pg_delta >= -(pg - pg_first_stage))
    end
end
function constraint_second_stage_redispatch_reactive_power_gen(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, first_stage_network_id) where T <: PowerModels.AbstractACPForm
    qg_delta = PowerModels.var(pm, n, cnd, :qg_delta, i)
    qg = PowerModels.var(pm, n, cnd, :qg, i)
    qg_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :qg, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, qg_delta == abs(qg - qg_first_stage))
    else
        @constraint(pm.model, qg_delta >= qg - qg_first_stage)
        @constraint(pm.model, qg_delta >= -(qg - qg_first_stage))
    end
end
function constraint_redispatch_active_power_load(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, pref::AbstractFloat) where T <: PowerModels.AbstractACPForm
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta, i)
    pl = PowerModels.var(pm, n, cnd, :pl, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, pl_delta == abs(pl - pref))
    else
        @constraint(pm.model, pl_delta >= pl - pref)
        @constraint(pm.model, pl_delta >= -(pl - pref))
    end
end
function constraint_redispatch_reactive_power_load(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, qref::AbstractFloat) where T <: PowerModels.AbstractACPForm
    ql_delta = PowerModels.var(pm, n, cnd, :ql_delta, i)
    ql = PowerModels.var(pm, n, cnd, :ql, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, ql_delta == abs(ql - qref))
    else
        @constraint(pm.model, ql_delta >= ql - qref)
        @constraint(pm.model, ql_delta >= -(ql - qref))
    end
end
function constraint_second_stage_redispatch_active_power_load(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, first_stage_network_id)  where T <: PowerModels.AbstractACPForm
    pl_delta = PowerModels.var(pm, n, cnd, :pl_delta, i)
    pl = PowerModels.var(pm, n, cnd, :pl, i)
    pl_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :pl, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, pl_delta == abs(pl - pl_first_stage))
    else
        @constraint(pm.model, pl_delta >= pl - pl_first_stage)
        @constraint(pm.model, pl_delta >= -(pl - pl_first_stage))
    end
end
function constraint_second_stage_redispatch_reactive_power_load(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, first_stage_network_id)  where T <: PowerModels.AbstractACPForm
    ql_delta = PowerModels.var(pm, n, cnd, :ql_delta, i)
    ql = PowerModels.var(pm, n, cnd, :ql, i)
    ql_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :ql, i)

    if pm.setting["relax_absolute_value"] == false
        @NLconstraint(pm.model, ql_delta == abs(ql - ql_first_stage))
    else
        @constraint(pm.model, ql_delta >= ql - ql_first_stage)
        @constraint(pm.model, ql_delta >= -(ql - ql_first_stage))
    end
end
