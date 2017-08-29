## CONSTRAINT TEMPLATES

""
function constraint_variable_transformer_y_from(pm::GenericPowerModel, branch)
    i = branch["index"]
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = PowerModels.calc_branch_y(branch)
    c = branch["br_b"]
    g_shunt = branch["g_shunt"]
    tap_min = branch["tap_fr_min"]
    tap_max = branch["tap_fr_max"]

    return constraint_variable_transformer_y_from(pm, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
end
""
function constraint_variable_transformer_y_to(pm::GenericPowerModel, branch)
    i = branch["index"]
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = PowerModels.calc_branch_y(branch)
    c = branch["br_b"]
    g_shunt = branch["g_shunt"]
    tap_min = branch["tap_to_min"]
    tap_max = branch["tap_to_max"]

    return constraint_variable_transformer_y_to(pm, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
end

""
function constraint_link_voltage_magnitudes(pm::GenericPowerModel, branch)
    i = branch["index"]
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    tap_fr = branch["tap"] # tap_fr = matpower tap, tap_fr = branch["tap_fr"]
    tap_to = 1.0 # tap_to = 1.0, tap_to = branch["tap_to"]

    return constraint_link_voltage_magnitudes(pm, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to)
end

## VARIABLE DEFINITIONS


function variable_transformation(pm::GenericPowerModel; kwargs...)
    variable_phase_shift(pm; kwargs...)
    variable_voltage_tap(pm; kwargs...)
end

"variable: `va_shift[l,i,j]` for `(l,i,j)` in `arcs`"
function variable_phase_shift(pm::GenericPowerModel; bounded = true)

    shift_min = Dict()
    shift_max = Dict()
    shift = Dict()
    for (l,i,j) in pm.ref[:arcs_from]
        shift_min[(l,i,j)] = pm.ref[:branch][l]["shift_fr_min"]
        shift_max[(l,i,j)] = pm.ref[:branch][l]["shift_fr_max"]
        shift[(l,i,j)] = pm.ref[:branch][l]["shift"] # shift_fr = matpower - shift
    end
    for (l,i,j) in pm.ref[:arcs_to]
        shift_min[(l,i,j)] = pm.ref[:branch][l]["shift_to_min"]
        shift_max[(l,i,j)] = pm.ref[:branch][l]["shift_to_max"]
        shift[(l,i,j)] = 0  # shift_to = 0
    end

    pm.var[:va_shift] = @variable(pm.model,
        [(l,i,j) in pm.ref[:arcs]], basename="va_shift",
        lowerbound = shift_min[(l,i,j)],
        upperbound = shift_max[(l,i,j)],
        start = shift[(l,i,j)]
    )

    return pm.var[:va_shift]
end

# ACTUAL CONSTRAINTS

"variable: `vm_tap[(l,i,j)]` for `(l,i,j)` in `arcs`"
function variable_voltage_tap(pm::GenericPowerModel; bounded = true)

    vm_tap_min = Dict()
    vm_tap_max = Dict()
    vm_tap = Dict()
    for (l,i,j) in pm.ref[:arcs_from]
        vm_tap_min[(l,i,j)] = pm.ref[:bus][i]["vmin"] / pm.ref[:branch][l]["tap_fr_max"]
        vm_tap_max[(l,i,j)] = pm.ref[:bus][i]["vmax"] / pm.ref[:branch][l]["tap_fr_min"]
        vm_tap[(l,i,j)] = pm.ref[:bus][i]["vm"] /pm.ref[:branch][l]["tap"]  # vm_tap[(l,i,j)] = pm.ref[:bus][i]["vm"] /pm.ref[:branch][l]["tap_fr"]
    end
    for (l,j,i) in pm.ref[:arcs_to]
        vm_tap_min[(l,j,i)] = pm.ref[:bus][j]["vmin"] / pm.ref[:branch][l]["tap_to_max"]
        vm_tap_max[(l,j,i)] = pm.ref[:bus][j]["vmax"] / pm.ref[:branch][l]["tap_to_min"]
        vm_tap[(l,j,i)] = pm.ref[:bus][i]["vm"] / 1  # vm_tap[(l,j,i)] = pm.ref[:bus][i]["vm"] /pm.ref[:branch][l]["tap_to"]
    end

    pm.var[:vm_tap] = @variable(pm.model,
        [(l,i,j) in pm.ref[:arcs]], basename="vm_tap",
        lowerbound = vm_tap_min[(l,i,j)],
        upperbound = vm_tap_max[(l,i,j)],
        start = vm_tap[(l,i,j)]
    )

    return pm.var[:vm_tap]
end


"""
Creates Ohms constraints for shiftable PSTs / OLTCs

```
p[f_idx] == g*vm_tap[f_idx]^2 + (-g)*(vm_tap[f_idx]*vm_tap[t_idx]*cos((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))) + (-b)*(vm_tap[f_idx]*vm_tap[t_idx]*sin((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))))
q[f_idx] == -(b+c/2)*vm_tap[f_idx]^2 - (-b)*(vm_tap[f_idx]*vm_tap[t_idx]*cos((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))) + (-g)*(vm_tap[f_idx]*vm_tap[t_idx]*sin((va[f_bus] - va_shift[f_idx]) - (va[t_bus] - va_shift[t_idx]))))
vm_tap[f_idx] * tap_min <= vm[f_bus] <= vm_tap[f_idx] * tap_max
```
"""
function constraint_variable_transformer_y_from(pm::GenericPowerModel, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
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
function constraint_variable_transformer_y_to(pm::GenericPowerModel, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
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

function constraint_link_voltage_magnitudes(pm::GenericPowerModel, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to)
    vm_fr = pm.var[:vm][f_bus]
    vm_to = pm.var[:vm][t_bus]
    vm_tap_fr = pm.var[:vm_tap][f_idx]
    vm_tap_to = pm.var[:vm_tap][t_idx]
    @constraint(pm.model, vm_tap_fr * tap_fr == vm_fr)
    @constraint(pm.model, vm_tap_to * tap_to == vm_to)
end
