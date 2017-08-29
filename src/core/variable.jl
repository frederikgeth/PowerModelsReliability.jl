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
        shift[(l,i,j)] = pm.ref[:branch][l]["shift_fr"] # shift_fr = matpower - shift
    end
    for (l,i,j) in pm.ref[:arcs_to]
        shift_min[(l,i,j)] = pm.ref[:branch][l]["shift_to_min"]
        shift_max[(l,i,j)] = pm.ref[:branch][l]["shift_to_max"]
        shift[(l,i,j)] = pm.ref[:branch][l]["shift_to"]
    end

    pm.var[:va_shift] = @variable(pm.model,
        [(l,i,j) in pm.ref[:arcs]], basename="va_shift",
        lowerbound = shift_min[(l,i,j)],
        upperbound = shift_max[(l,i,j)],
        start = shift[(l,i,j)]
    )

    return pm.var[:va_shift]
end

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
