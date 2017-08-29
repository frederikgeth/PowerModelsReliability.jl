"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == -b*((t[f_bus] - t_shift[f_idx]) - (t[t_bus] - t_shift[t_idx]))
```
"""
function constraint_variable_transformer_y_from{T <: AbstractDCPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
    p_fr = pm.var[:p][f_idx]
    va_fr = pm.var[:va][f_bus]
    va_to = pm.var[:va][t_bus]
    va_shift_fr = pm.var[:va_shift][f_idx]
    va_shift_to = pm.var[:va_shift][t_idx]

    @constraint(pm.model, p_fr ==  g_shunt/2 + (-b)*((va_fr - va_shift_fr) - (va_to - va_shift_to)))
    # omit reactive constraint
end

"Do nothing, this model is symmetric"
constraint_variable_transformer_y_to{T <: AbstractDCPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max) = Set()

"Do nothing, there are no voltage magnitude variables"
constraint_link_voltage_magnitudes{T <: AbstractDCPForm}(pm::GenericPowerModel{T}, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to) = Set()
