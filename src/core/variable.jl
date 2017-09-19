function variable_transformation(pm::GenericPowerModel; kwargs...)
    variable_phase_shift(pm; kwargs...)
    variable_voltage_tap(pm; kwargs...)
end

"variable: `va_shift[l,i,j]` for `(l,i,j)` in `arcs`"
function variable_phase_shift(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)

    shift_min = Dict()
    shift_max = Dict()
    shift = Dict()
    for (l,i,j) in PowerModels.ref(pm, :arcs_from)
        shift_min[(l,i,j)] = PowerModels.ref(pm, :branch)[l]["shift_fr_min"]
        shift_max[(l,i,j)] = PowerModels.ref(pm, :branch)[l]["shift_fr_max"]
        shift[(l,i,j)] = PowerModels.ref(pm, :branch)[l]["shift_fr"] # shift_fr = matpower - shift
    end
    for (l,i,j) in PowerModels.ref(pm, :arcs_to)
        shift_min[(l,i,j)] = PowerModels.ref(pm, :branch)[l]["shift_to_min"]
        shift_max[(l,i,j)] = PowerModels.ref(pm, :branch)[l]["shift_to_max"]
        shift[(l,i,j)] = PowerModels.ref(pm, :branch)[l]["shift_to"]
    end

    pm.var[:nw][n][:va_shift] = @variable(pm.model,
        [(l,i,j) in PowerModels.ref(pm, :arcs)], basename="va_shift",
        lowerbound = shift_min[(l,i,j)],
        upperbound = shift_max[(l,i,j)],
        start = shift[(l,i,j)]
    )

    return pm.var[:nw][n][:va_shift]
end

"variable: `vm_tap[(l,i,j)]` for `(l,i,j)` in `arcs`"
function variable_voltage_tap(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)

    vm_tap_min = Dict()
    vm_tap_max = Dict()
    vm_tap = Dict()
    for (l,i,j) in PowerModels.ref(pm, :arcs_from)
        vm_tap_min[(l,i,j)] = PowerModels.ref(pm, :bus)[i]["vmin"] / PowerModels.ref(pm, :branch)[l]["tap_fr_max"]
        vm_tap_max[(l,i,j)] = PowerModels.ref(pm, :bus)[i]["vmax"] / PowerModels.ref(pm, :branch)[l]["tap_fr_min"]
        vm_tap[(l,i,j)] = PowerModels.ref(pm, :bus)[i]["vm"] /PowerModels.ref(pm, :branch)[l]["tap"]  # vm_tap[(l,i,j)] = PowerModels.ref(pm, :bus][i]["vm"] /PowerModels.ref(pm, :branch][l]["tap_fr"]
    end
    for (l,j,i) in PowerModels.ref(pm, :arcs_to)
        vm_tap_min[(l,j,i)] = PowerModels.ref(pm, :bus)[j]["vmin"] / PowerModels.ref(pm, :branch)[l]["tap_to_max"]
        vm_tap_max[(l,j,i)] = PowerModels.ref(pm, :bus)[j]["vmax"] / PowerModels.ref(pm, :branch)[l]["tap_to_min"]
        vm_tap[(l,j,i)] = PowerModels.ref(pm, :bus)[i]["vm"] / 1  # vm_tap[(l,j,i)] = PowerModels.ref(pm, :bus][i]["vm"] /PowerModels.ref(pm, :branch][l]["tap_to"]
    end

    pm.var[:nw][n][:vm_tap] = @variable(pm.model,
        [(l,i,j) in PowerModels.ref(pm, :arcs)], basename="vm_tap",
        lowerbound = vm_tap_min[(l,i,j)],
        upperbound = vm_tap_max[(l,i,j)],
        start = vm_tap[(l,i,j)]
    )

    return pm.var[:nw][n][:vm_tap]
end

"variable unit aggregation"

function variable_node_aggregation(pm, n::Int=pm.cnw)
    pm.var[:nw][n][:pnode] = @variable(pm.model,
    [i in keys(PowerModels.ref(pm, :bus))], basename="pnode",
    start = PowerModels.getstart(PowerModels.ref(pm, :bus), i, 0)
    )

    pm.var[:nw][n][:qnode] =@variable(pm.model,
    [i in keys(PowerModels.ref(pm, :bus))], basename="qnode",
    start = PowerModels.getstart(PowerModels.ref(pm, :bus), i, 0)
    )
end

"generates variables for both `active` and `reactive` load"
function variable_load(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_active_load(pm, n; kwargs...)
    variable_reactive_load(pm, n; kwargs...)
end

"variable: `pl[j]` for `j` in `load`"
function variable_active_load(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    if bounded
        pm.var[:nw][n][:pl] = @variable(pm.model,
            [i in keys(PowerModels.ref(pm, :load))], basename="pl",
            lowerbound = PowerModels.ref(pm, :load)[i]["pmin"],
            upperbound = PowerModels.ref(pm, :load)[i]["pmax"],
            start = PowerModels.getstart(PowerModels.ref(pm, :load), i, "pl_start")
        )
    else
        pm.var[:nw][n][:pl] = @variable(pm.model,
            [i in keys(PowerModels.ref(pm, :load))], basename="pl",
            start = PowerModels.getstart(PowerModels.ref(pm, :load), i, "pl_start")
        )
    end
end

"variable: `ql[j]` for `j` in `load`"
function variable_reactive_load(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    if bounded
        pm.var[:nw][n][:ql] = @variable(pm.model,
            [i in keys(PowerModels.ref(pm, :load))], basename="ql",
            lowerbound = PowerModels.ref(pm, :load)[i]["qmin"],
            upperbound = PowerModels.ref(pm, :load)[i]["qmax"],
            start = PowerModels.getstart(PowerModels.ref(pm, :load), i, "ql_start")
        )
    else
        pm.var[:nw][n][:ql] = @variable(pm.model,
            [i in keys(PowerModels.ref(pm, :load))], basename="ql",
            start = PowerModels.getstart(PowerModels.ref(pm, :load), i, "ql_start")
        )
    end
end

"generates variables for both `generator` and `load` action indicators"
function variable_action_indicator(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_load_action_indicator(pm, n; kwargs...)
    variable_gen_action_indicator(pm, n; kwargs...)
end

function variable_load_action_indicator(pm::GenericPowerModel, n::Int=pm.cnw)
    pm.var[:nw][n][:load_ind] = @variable(pm.model,
        [l in keys(PowerModels.ref(pm, :load))], basename="load_ind",
        lowerbound = 0,
        upperbound = 1,
        category = :Int,
        start = PowerModels.getstart(PowerModels.ref(pm, :load), l, "void", 0)
    )
end

function variable_gen_action_indicator(pm::GenericPowerModel, n::Int=pm.cnw)
    pm.var[:nw][n][:gen_ind] = @variable(pm.model,
        [g in keys(PowerModels.ref(pm, :gen))], basename="gen_ind",
        lowerbound = 0,
        upperbound = 1,
        category = :Int,
        start = PowerModels.getstart(PowerModels.ref(pm, :gen), g, "void", 0)
    )
end

function variable_auxiliary_power(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_auxiliary_power_load(pm, n; kwargs...)
    variable_auxiliary_power_gen(pm, n; kwargs...)
end

function variable_auxiliary_power_load(pm::GenericPowerModel, n::Int=pm.cnw)
    pm.var[:nw][n][:pl_delta] = @variable(pm.model,
        [l in keys(PowerModels.ref(pm, :load))], basename="pl_delta",
        lowerbound = 0,
        upperbound = 2 * PowerModels.ref(pm, :load)[l]["prated"],
        start = PowerModels.getstart(PowerModels.ref(pm, :load), l, "void", 0)
    )
end

function variable_auxiliary_power_gen(pm::GenericPowerModel, n::Int=pm.cnw)
    pm.var[:nw][n][:pg_delta] = @variable(pm.model,
        [g in keys(PowerModels.ref(pm, :gen))], basename="pg_delta",
        lowerbound = 0,
        upperbound = 2 * PowerModels.ref(pm, :gen)[g]["prated"],
        start = PowerModels.getstart(PowerModels.ref(pm, :gen), g, "void", 0)
    )
end
