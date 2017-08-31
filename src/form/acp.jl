"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == g*vm_tap[f_idx]^2 + (-g)*(vm_tap[f_idx]*vm_tap[t_idx]*cos((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))) + (-b)*(vm_tap[f_idx]*vm_tap[t_idx]*sin((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))))
q[f_idx] == -(b+c/2)*vm_tap[f_idx]^2 - (-b)*(vm_tap[f_idx]*vm_tap[t_idx]*cos((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))) + (-g)*(vm_tap[f_idx]*vm_tap[t_idx]*sin((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))))
vm_tap[f_idx] * tap_min <= vm[f_bus] <= vm_tap[f_idx] * tap_max
```
"""
function constraint_variable_transformer_y_from{T <: PowerModels.AbstractACPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
    p_fr = pm.var[:p][f_idx]
    q_fr = pm.var[:q][f_idx]
    vm_fr = pm.var[:vm][f_bus]
    vm_to = pm.var[:vm][t_bus]
    va_fr = pm.var[:va][f_bus]
    va_to = pm.var[:va][t_bus]
    va_shift_fr = pm.var[:va_shift][f_idx]
    va_shift_to = pm.var[:va_shift][t_idx]
    vm_tap_fr = pm.var[:vm_tap][f_idx]
    vm_tap_to = pm.var[:vm_tap][t_idx]

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
function constraint_variable_transformer_y_to{T <: PowerModels.AbstractACPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
    p_to = pm.var[:p][t_idx]
    q_to = pm.var[:q][t_idx]
    vm_fr = pm.var[:vm][f_bus]
    vm_to = pm.var[:vm][t_bus]
    va_fr = pm.var[:va][f_bus]
    va_to = pm.var[:va][t_bus]
    va_shift_fr = pm.var[:va_shift][f_idx]
    va_shift_to = pm.var[:va_shift][t_idx]
    vm_tap_fr = pm.var[:vm_tap][f_idx]
    vm_tap_to = pm.var[:vm_tap][t_idx]

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

function constraint_link_voltage_magnitudes{T <: PowerModels.AbstractACPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to)
    vm_fr = pm.var[:vm][f_bus]
    vm_to = pm.var[:vm][t_bus]
    vm_tap_fr = pm.var[:vm_tap][f_idx]
    vm_tap_to = pm.var[:vm_tap][t_idx]
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
function constraint_kcl_shunt_aggregated{T <: PowerModels.AbstractACPForm}(pm::GenericPowerModel{T}, i, bus_arcs, bus_arcs_dc, gs, bs)
    vm = pm.var[:vm][i]
    p = pm.var[:p]
    q = pm.var[:q]
    pnode = pm.var[:pnode][i]
    qnode = pm.var[:qnode][i]
    p_dc = pm.var[:p_dc]
    q_dc = pm.var[:q_dc]

    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == pnode - gs*vm^2)
    @constraint(pm.model, sum(q[a] for a in bus_arcs) + sum(q_dc[a_dc] for a_dc in bus_arcs_dc) == qnode + bs*vm^2)
end
