"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == -b*((t[f_bus] - t_shift[f_idx]) - (t[t_bus] - t_shift[t_idx]))
```
"""
function constraint_variable_transformer_y_from{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
    p_fr = PowerModels.var(pm, n, :p)[f_idx]
    va_fr = PowerModels.var(pm, n, :va)[f_bus]
    va_to = PowerModels.var(pm, n, :va)[t_bus]
    va_shift_fr = PowerModels.var(pm, n, :va_shift)[f_idx]
    va_shift_to = PowerModels.var(pm, n, :va_shift)[t_idx]

    @constraint(pm.model, p_fr ==  g_shunt/2 + (-b)*((va_fr - va_shift_fr) - (va_to - va_shift_to)))
    # omit reactive constraint
end

"Do nothing, this model is symmetric"
constraint_variable_transformer_y_to{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max) = Set()

"Do nothing, there are no voltage magnitude variables"
constraint_link_voltage_magnitudes{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to) = Set()


""
function constraint_kcl_shunt_aggregated{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i, bus_arcs, bus_arcs_dc, gs, bs)
    p = PowerModels.var(pm, n, :p)
    p_dc = PowerModels.var(pm, n, :p_dc)
    pnode = PowerModels.var(pm, n, :pnode)[i]

    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == pnode - gs*1.0^2)
    # omit reactive constraint
end


function constraint_flexible_gen{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
        constraint_flexible_active_gen(pm, n, i)
end

function constraint_flexible_load{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
        constraint_flexible_active_load(pm, n, i)
end

function constraint_fixed_load{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
        constraint_fixed_active_load(pm, n, i)
end

function constraint_load_gen_aggregation_sheddable{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
    constraint_active_load_gen_aggregation_sheddable(pm, n, i)
end

function constraint_load_gen_aggregation{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
        constraint_active_load_gen_aggregation(pm, n, i)
end

function constraint_redispatch_power_gen{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
        constraint_redispatch_active_power_gen(pm, n, i)
end

function constraint_gen_contingency{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
    constraint_active_power_gen_contingency(pm, n, i)
end

function constraint_branch_contingency{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int)
    constraint_active_power_branch_contingency(pm, n, i)
end

function constraint_second_stage_redispatch_power_gen{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int, first_stage_network_id)
    constraint_second_stage_redispatch_active_power_gen(pm, n, i, first_stage_network_id)
end

function constraint_second_stage_redispatch_power_load{T <: PowerModels.AbstractDCPForm}(pm::GenericPowerModel{T}, n::Int, i::Int, first_stage_network_id)
    constraint_second_stage_redispatch_active_power_load(pm, n, i, first_stage_network_id)
end
