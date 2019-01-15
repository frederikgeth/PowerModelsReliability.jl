"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == -b*((t[f_bus] - t_shift[f_idx]) - (t[t_bus] - t_shift[t_idx]))
```
"""
function constraint_variable_transformer_y_from(pm::GenericPowerModel{T}, n::Int, cnd::Int, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max) where T <: PowerModels.AbstractDCPForm
    p_fr = PowerModels.var(pm, n, cnd, :p, f_idx)
    va_fr = PowerModels.var(pm, n, cnd, :va, f_bus)
    va_to = PowerModels.var(pm, n, cnd, :va, t_bus)
    va_shift_fr = PowerModels.var(pm, n, cnd, :va_shift, f_idx)
    va_shift_to = PowerModels.var(pm, n, cnd, :va_shift, t_idx)

    @constraint(pm.model, p_fr ==  g_shunt/2 + (-b)*((va_fr - va_shift_fr) - (va_to - va_shift_to)))
    # omit reactive constraint
end

"Do nothing, this model is symmetric"
function constraint_variable_transformer_y_to(pm::GenericPowerModel{T}, n::Int, cnd::Int, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max) where T <: PowerModels.AbstractDCPForm
end
"Do nothing, there are no voltage magnitude variables"
function constraint_link_voltage_magnitudes(pm::GenericPowerModel{T}, n::Int, cnd::Int, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to) where T <: PowerModels.AbstractDCPForm
end

""
function constraint_kcl_shunt_aggregated(pm::GenericPowerModel{T}, n::Int, cnd::Int, i, bus_arcs, bus_arcs_dc, bus_gs, bus_bs) where T <: PowerModels.AbstractDCPForm
    p = PowerModels.var(pm, n, cnd, :p)
    p_dc = PowerModels.var(pm, n, cnd, :p_dc)
    pnode = PowerModels.var(pm, n, cnd, :pnode, i)

    @constraint(pm.model, sum(p[a] for a in bus_arcs) + sum(p_dc[a_dc] for a_dc in bus_arcs_dc) == pnode - sum(gs for gs in values(bus_gs))*1.0^2)
    # omit reactive constraint
end


function constraint_flexible_gen(pm::GenericPowerModel{T}, i::Int;  nw::Int = pm.cnw, cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
        constraint_flexible_active_gen(pm, nw, cnd, i)
end

function constraint_flexible_load(pm::GenericPowerModel{T}, i::Int;  nw::Int = pm.cnw, cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
        constraint_flexible_active_load(pm, nw, cnd,  i)
end

function constraint_fixed_load(pm::GenericPowerModel{T}, i::Int;  nw::Int = pm.cnw, cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
        constraint_fixed_active_load(pm, nw, cnd, i)
end

function constraint_load_gen_aggregation_sheddable(pm::GenericPowerModel{T}, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
    constraint_active_load_gen_aggregation_sheddable(pm, nw, cnd, i)
end

function constraint_load_gen_aggregation(pm::GenericPowerModel{T}, i::Int;  nw::Int = pm.cnw, cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
        constraint_active_load_gen_aggregation(pm, nw, cnd, i)
end

function constraint_redispatch_power_gen(pm::GenericPowerModel{T}, i::Int;  nw::Int = pm.cnw, cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
        constraint_redispatch_active_power_gen(pm, nw, cnd, i)
end

function constraint_gen_contingency(pm::GenericPowerModel{T}, n::Int, i::Int; cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
    constraint_active_power_gen_contingency(pm, n, cnd, i)
end

function constraint_branch_contingency(pm::GenericPowerModel{T}, n::Int, i::Int; cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
    constraint_active_power_branch_contingency(pm, n, cnd, i)
end

function constraint_second_stage_redispatch_power_gen(pm::GenericPowerModel{T}, n::Int, i::Int, first_stage_network_id; cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
    constraint_second_stage_redispatch_active_power_gen(pm, n, cnd, i, first_stage_network_id)
end

function constraint_second_stage_redispatch_power_load(pm::GenericPowerModel{T}, n::Int, i::Int, first_stage_network_id; cnd::Int = pm.ccnd) where T <: PowerModels.AbstractDCPForm
    constraint_second_stage_redispatch_active_power_load(pm, n, cnd, i, first_stage_network_id)
end

function constraint_redispatch_active_power_gen(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, pref::AbstractFloat) where T <: PowerModels.AbstractDCPForm
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)

    @constraint(pm.model, pg_delta >= pg - pref)
    @constraint(pm.model, pg_delta >= -(pg - pref))
end
# DO Nothing
function constraint_redispatch_reactive_power_gen(pm::GenericPowerModel{T}, n::Int,  cnd::Int, i::Int, qref::AbstractFloat) where T <: PowerModels.AbstractDCPForm
end

function constraint_second_stage_redispatch_active_power_gen(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, first_stage_network_id) where T <: PowerModels.AbstractDCPForm
    pg_delta = PowerModels.var(pm, n, cnd, :pg_delta, i)
    pg = PowerModels.var(pm, n, cnd, :pg, i)
    pg_first_stage = PowerModels.var(pm, first_stage_network_id, cnd, :pg, i)

    @constraint(pm.model, pg_delta >= pg - pg_first_stage)
    @constraint(pm.model, pg_delta >= -(pg - pg_first_stage))
end

# DO Nothing
function constraint_second_stage_redispatch_reactive_power_gen(pm::GenericPowerModel{T}, n::Int, cnd::Int, i::Int, first_stage_network_id) where T <: PowerModels.AbstractDCPForm
end
