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

"variable unit aggregation"

function variable_node_aggregation(pm)
    pm.var[:pnode] = @variable(pm.model,
    [i in keys(pm.ref[:bus])], basename="pnode",
    start = PowerModels.getstart(pm.ref[:bus], i, 0)
    )

    pm.var[:qnode] =@variable(pm.model,
    [i in keys(pm.ref[:bus])], basename="qnode",
    start = PowerModels.getstart(pm.ref[:bus], i, 0)
    )
end

"generates variables for both `active` and `reactive` load"
function variable_load(pm::GenericPowerModel; kwargs...)
    variable_active_load(pm; kwargs...)
    variable_reactive_load(pm; kwargs...)
end

"variable: `pl[j]` for `j` in `load`"
function variable_active_load(pm::GenericPowerModel; bounded = true)
    if bounded
        pm.var[:pl] = @variable(pm.model,
            [i in keys(pm.ref[:load])], basename="pl",
            lowerbound = pm.ref[:load][i]["pmin"],
            upperbound = pm.ref[:load][i]["pmax"],
            start = PowerModels.getstart(pm.ref[:load], i, "pl_start")
        )
    else
        pm.var[:pl] = @variable(pm.model,
            [i in keys(pm.ref[:load])], basename="pl",
            start = PowerModels.getstart(pm.ref[:load], i, "pl_start")
        )
    end
end

"variable: `ql[j]` for `j` in `load`"
function variable_reactive_load(pm::GenericPowerModel; bounded = true)
    if bounded
        pm.var[:ql] = @variable(pm.model,
            [i in keys(pm.ref[:load])], basename="ql",
            lowerbound = pm.ref[:load][i]["qmin"],
            upperbound = pm.ref[:load][i]["qmax"],
            start = PowerModels.getstart(pm.ref[:load], i, "ql_start")
        )
    else
        pm.var[:ql] = @variable(pm.model,
            [i in keys(pm.ref[:load])], basename="ql",
            start = PowerModels.getstart(pm.ref[:load], i, "ql_start")
        )
    end
end

"generates variables for both `generator` and `load` action indicators"
function variable_action_indicator(pm::GenericPowerModel; kwargs...)
    variable_load_action_indicator(pm; kwargs...)
    variable_gen_action_indicator(pm; kwargs...)
end

function variable_load_action_indicator(pm::GenericPowerModel)
    pm.var[:load_ind] = @variable(pm.model,
        [l in keys(pm.ref[:load])], basename="load_ind",
        lowerbound = 0,
        upperbound = 1,
        category = :Int,
        start = PowerModels.getstart(pm.ref[:load], l, "void", 0)
    )
end

function variable_gen_action_indicator(pm::GenericPowerModel)
    pm.var[:gen_ind] = @variable(pm.model,
        [g in keys(pm.ref[:gen])], basename="gen_ind",
        lowerbound = 0,
        upperbound = 1,
        category = :Int,
        start = PowerModels.getstart(pm.ref[:gen], g, "void", 0)
    )
end

function variable_auxiliary_power(pm::GenericPowerModel; kwargs...)
    variable_auxiliary_power_load(pm; kwargs...)
    variable_auxiliary_power_gen(pm; kwargs...)
end

function variable_auxiliary_power_load(pm::GenericPowerModel)
    pm.var[:pl_delta] = @variable(pm.model,
        [l in keys(pm.ref[:load])], basename="pl_delta",
        lowerbound = 0,
        upperbound = 2 * pm.ref[:load][l]["prated"],
        start = PowerModels.getstart(pm.ref[:load], l, "void", 0)
    )
end

function variable_auxiliary_power_gen(pm::GenericPowerModel)
    pm.var[:pg_delta] = @variable(pm.model,
        [g in keys(pm.ref[:gen])], basename="pg_delta",
        lowerbound = 0,
        upperbound = 2 * pm.ref[:gen][g]["prated"],
        start = PowerModels.getstart(pm.ref[:gen], g, "void", 0)
    )
end
