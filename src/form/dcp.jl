"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == -b*((t[f_bus] - t_shift[f_idx]) - (t[t_bus] - t_shift[t_idx]))
```
"""
function constraint_variable_transformer_y_from{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
    p_fr = pm.var[:p][f_idx]
    va_fr = pm.var[:va][f_bus]
    va_to = pm.var[:va][t_bus]
    va_shift_fr = pm.var[:va_shift][f_idx]
    va_shift_to = pm.var[:va_shift][t_idx]

    @constraint(pm.model, p_fr ==  g_shunt/2 + (-b)*((va_fr - va_shift_fr) - (va_to - va_shift_to)))
    # omit reactive constraint
end

"Do nothing, this model is symmetric"
constraint_variable_transformer_y_to{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max) = Set()

"Do nothing, there are no voltage magnitude variables"
constraint_link_voltage_magnitudes{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to) = Set()


""
function constraint_kcl_shunt_aggregated{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, i, bus_arcs, bus_arcs_dc, gs, bs)
    p = pm.var[:p]
    p_dc = pm.var[:p_dc]
    pnode = pm.var[:pnode][i]

    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == pnode - gs*1.0^2)
    # omit reactive constraint
end


function constraint_flexible_gen{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, gen)
        constraint_flexible_active_gen(pm, gen)
end

function constraint_flexible_load{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, load)
        constraint_flexible_active_gen(pm, load)
end

function contraint_load_gen_aggregation_sheddable{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, bus)
    contraint_active_load_gen_aggregation_sheddable(pm, bus)
end

function contraint_load_gen_aggregation{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, bus)
        contraint_active_load_gen_aggregation(pm, bus)
end
