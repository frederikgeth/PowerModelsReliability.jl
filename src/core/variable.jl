function variable_transformation(pm::GenericPowerModel; kwargs...)
    variable_phase_shift(pm; kwargs...)
    variable_voltage_tap(pm; kwargs...)
end

"variable: `va_shift[l,i,j]` for `(l,i,j)` in `arcs`"
function variable_phase_shift(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)

    shift_min = Dict()
    shift_max = Dict()
    shift = Dict()
    for (l,i,j) in PowerModels.ref(pm, nw, :arcs_from)
        shift_min[(l,i,j)] = PowerModels.ref(pm, nw, :branch, l, "shift_fr_min", cnd)
        shift_max[(l,i,j)] = PowerModels.ref(pm, nw, :branch, l, "shift_fr_max", cnd)
        shift[(l,i,j)] = PowerModels.ref(pm, nw, :branch, l, "shift_fr", cnd) # shift_fr = matpower - shift
    end
    for (l,i,j) in PowerModels.ref(pm, nw, :arcs_to)
        shift_min[(l,i,j)] = PowerModels.ref(pm, nw, :branch, l, "shift_to_min", cnd)
        shift_max[(l,i,j)] = PowerModels.ref(pm, nw, :branch, l, "shift_to_max", cnd)
        shift[(l,i,j)] = PowerModels.ref(pm, nw, :branch, l, "shift_to", cnd)
    end

    PowerModels.var(pm, nw, cnd)[:va_shift] = @variable(pm.model,
        [(l,i,j) in PowerModels.ref(pm, nw, :arcs)], basename="va_shift",
        lowerbound = shift_min[(l,i,j)],
        upperbound = shift_max[(l,i,j)],
        start = shift[(l,i,j)]
    )

    return PowerModels.var(pm, nw, cnd)[:va_shift]
end

"variable: `vm_tap[(l,i,j)]` for `(l,i,j)` in `arcs`"
function variable_voltage_tap(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)

    vm_tap_min = Dict()
    vm_tap_max = Dict()
    vm_tap = Dict()
    for (l,i,j) in PowerModels.ref(pm, nw, :arcs_from)
        vm_tap_min[(l,i,j)] = PowerModels.ref(pm, nw, :bus, i, "vmin", cnd) / PowerModels.ref(pm, nw, :branch, l, "tap_fr_max", cnd)
        vm_tap_max[(l,i,j)] = PowerModels.ref(pm, nw, :bus, i, "vmax", cnd) / PowerModels.ref(pm, nw, :branch, l, "tap_fr_min", cnd)
        vm_tap[(l,i,j)] = PowerModels.ref(pm, nw, :bus, i, "vm", cnd) /PowerModels.ref(pm, nw, :branch, l, "tap", cnd)  # vm_tap[(l,i,j)] = PowerModels.ref(pm, :bus][i]["vm"] /PowerModels.ref(pm, :branch][l]["tap_fr"]
    end
    for (l,j,i) in PowerModels.ref(pm, nw, :arcs_to)
        vm_tap_min[(l,j,i)] = PowerModels.ref(pm, nw, :bus, j, "vmin", cnd) / PowerModels.ref(pm, nw, :branch, l, "tap_to_max", cnd)
        vm_tap_max[(l,j,i)] = PowerModels.ref(pm, nw, :bus, j, "vmax", cnd) / PowerModels.ref(pm, nw, :branch, l, "tap_to_min", cnd)
        vm_tap[(l,j,i)] = PowerModels.ref(pm, nw, :bus, i, "vm", cnd) / 1  # vm_tap[(l,j,i)] = PowerModels.ref(pm, :bus][i]["vm"] /PowerModels.ref(pm, :branch][l]["tap_to"]
    end

    PowerModels.var(pm, nw, cnd)[:vm_tap] = @variable(pm.model,
        [(l,i,j) in PowerModels.ref(pm, nw, :arcs)], basename="vm_tap",
        lowerbound = vm_tap_min[(l,i,j)],
        upperbound = vm_tap_max[(l,i,j)],
        start = vm_tap[(l,i,j)]
    )

    PowerModels.var(pm, nw, cnd)[:vm_tap]
end

"variable unit aggregation"

function variable_node_aggregation(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm, nw, cnd)[:pnode] = @variable(pm.model,
    [i in PowerModels.ids(pm, nw, :bus)], basename="pnode",
    #start = PowerModels.getval(PowerModels.ref(pm, nw, :bus, i), "void", cnd, 0)
    )

    PowerModels.var(pm, nw, cnd)[:qnode] =@variable(pm.model,
    [i in PowerModels.ids(pm, nw, :bus)], basename="qnode",
    #start = PowerModels.getval(PowerModels.ref(pm, nw, :bus, i), "void", cnd, 0)
    )

    return PowerModels.var(pm, nw, cnd)[:pnode], PowerModels.var(pm, nw, cnd)[:qnode]
end
"generates variables for both `active` and `reactive` load"
function variable_load(pm::GenericPowerModel; kwargs...)
    variable_active_load(pm; kwargs...)
    variable_reactive_load(pm; kwargs...)
end

"variable: `pl[j]` for `j` in `load`"
function variable_active_load(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    if bounded
        PowerModels.var(pm, nw, cnd)[:pl] = @variable(pm.model,
            [i in PowerModels.ids(pm, nw, :load)], basename="pl",
            lowerbound = PowerModels.ref(pm, nw, :load, i, "pmin", cnd),
            upperbound = PowerModels.ref(pm, nw, :load, i, "pmax", cnd),
            start = PowerModels.getval(PowerModels.ref(pm, nw, :load, i), "pl_start", cnd)
        )
    else
        PowerModels.var(pm, nw, cnd)[:pl] = @variable(pm.model,
            [i in PowerModels.ids(pm, nw, :load)], basename="pl",
            start = PowerModels.getval(PowerModels.ref(pm, nw, :load, i), "pl_start", cnd)
        )
    end
end

"variable: `ql[j]` for `j` in `load`"
function variable_reactive_load(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    if bounded
        PowerModels.var(pm, nw, cnd)[:ql] = @variable(pm.model,
            [i in PowerModels.ids(pm, nw, :load)], basename="ql",
            lowerbound = PowerModels.ref(pm, nw, :load, i, "qmin", cnd),
            upperbound = PowerModels.ref(pm, nw, :load, i, "qmax", cnd),
            start = PowerModels.getval(PowerModels.ref(pm, nw, :load, i), "ql_start", cnd)
        )
    else
        PowerModels.var(pm, nw, cnd)[:ql] = @variable(pm.model,
            [i in PowerModels.ids(pm, nw, :load)], basename="ql",
            start = PowerModels.getval(PowerModels.ref(pm, nw, :load, i), "ql_start", cnd)
        )
    end
end

"generates variables for both `generator` and `load` action indicators"
function variable_action_indicator(pm::GenericPowerModel; kwargs...)
    variable_load_action_indicator(pm; kwargs...)
    variable_gen_action_indicator(pm; kwargs...)
end

function variable_load_action_indicator(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    if haskey(pm.setting,"relax_continuous") && pm.setting["relax_continuous"] == true
        PowerModels.var(pm, nw, cnd)[:load_ind] = @variable(pm.model,
            [l in PowerModels.ids(pm, nw, :load)], basename="load_ind",
            lowerbound = 1,
            upperbound = 1,
            #start = PowerModels.getval(PowerModels.ref(pm, nw, :load, l), "void", cnd, 0)
        )
    else
        PowerModels.var(pm, nw, cnd)[:load_ind] = @variable(pm.model,
            [l in PowerModels.ids(pm, nw, :load)], basename="load_ind",
            lowerbound = 0,
            upperbound = 1,
            category = :Int,
            #start = PowerModels.getval(PowerModels.ref(pm, nw, :load, l), "void", cnd, 0)
        )
    end
end

function variable_gen_action_indicator(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    if haskey(pm.setting,"relax_continuous") && pm.setting["relax_continuous"] == true
        PowerModels.var(pm, nw, cnd)[:gen_ind] = @variable(pm.model,
            [g in PowerModels.ids(pm, nw, :gen)], basename="gen_ind",
            lowerbound = 1,
            upperbound = 1,
            #start = PowerModels.getval(PowerModels.ref(pm, nw, :gen, g), "void", cnd, 0)
            )
    else
        PowerModels.var(pm, nw, cnd)[:gen_ind] = @variable(pm.model,
            [g in PowerModels.ids(pm, nw, :gen)], basename="gen_ind",
            lowerbound = 0,
            upperbound = 1,
            category = :Int,
            #start = PowerModels.getval(PowerModels.ref(pm, nw, :gen, g), "void", cnd, 0)
            )
    end
end

function variable_auxiliary_power(pm::GenericPowerModel; kwargs...)
    variable_auxiliary_active_power_load(pm; kwargs...)
    variable_auxiliary_reactive_power_load(pm; kwargs...)
    variable_auxiliary_active_power_gen(pm; kwargs...)
    variable_auxiliary_reactive_power_gen(pm; kwargs...)
end

function variable_auxiliary_active_power_load(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm, nw, cnd)[:pl_delta] = @variable(pm.model,
        [l in PowerModels.ids(pm, nw, :load)], basename="pl_delta",
        lowerbound = 0,
        upperbound = 2 * PowerModels.ref(pm, nw, :load, l, "prated", cnd),
        #start = PowerModels.getval(PowerModels.ref(pm, nw, :load, l), "void", cnd, 0)
    )
end

function variable_auxiliary_reactive_power_load(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm, nw, cnd)[:ql_delta] = @variable(pm.model,
        [l in PowerModels.ids(pm, nw, :load)], basename="ql_delta",
        lowerbound = 0,
        upperbound = 2 * PowerModels.ref(pm, nw, :load, l, "qrated", cnd),
        #start = PowerModels.getval(PowerModels.ref(pm, nw, :load, l), "void", cnd, 0)
    )
end

function variable_auxiliary_active_power_gen(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm, nw, cnd)[:pg_delta] = @variable(pm.model,
        [g in PowerModels.ids(pm, nw, :gen)], basename="pg_delta",
        lowerbound = 0,
        upperbound = 2 * PowerModels.ref(pm, nw, :gen, g, "prated", cnd),
        #start = PowerModels.getval(PowerModels.ref(pm, nw, :gen, g), "void", cnd, 0)
    )
end

function variable_auxiliary_reactive_power_gen(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm, nw, cnd)[:qg_delta] = @variable(pm.model,
        [g in PowerModels.ids(pm, nw, :gen)], basename="qg_delta",
        lowerbound = 0,
        upperbound = 2 * PowerModels.ref(pm, nw, :gen, g, "qrated", cnd),
        #start = PowerModels.getval(PowerModels.ref(pm, nw, :gen, g), "void", cnd, 0)
    )
end

function variable_risk(pm::GenericPowerModel; kwargs...)
    variable_first_stage_cost(pm; kwargs...)
    variable_second_stage_risk(pm; kwargs...)
end

function variable_first_stage_cost(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm)[:first_stage_cost] = @variable(pm.model,
        basename="first_stage_cost",
        lowerbound = 0,
        upperbound = Inf,
        start = 0)
end

function variable_second_stage_risk(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm)[:second_stage_risk] = @variable(pm.model,
        basename="second_stage_risk",
        lowerbound = 0,
        upperbound = Inf,
        start = 0)
end

function variable_dispatch_cost(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm)[:dispatch_cost] = @variable(pm.model, [n in keys(PowerModels.nws(pm))],
        basename="dispatch_cost",
        lowerbound = 0,
        upperbound = Inf,
        start = 0)
end

function variable_redispatch_cost(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm)[:redispatch_cost] = @variable(pm.model, [n in keys(PowerModels.nws(pm))],
        basename="redispatch_cost",
        lowerbound = 0,
        upperbound = Inf,
        start = 0)
end

function variable_loadshedding_cost(pm::GenericPowerModel; nw::Int=pm.cnw, cnd::Int=pm.ccnd, bounded::Bool = true)
    PowerModels.var(pm)[:loadshedding_cost] = @variable(pm.model, [n in keys(PowerModels.nws(pm))],
        basename="loadshedding_cost",
        lowerbound = 0,
        upperbound = Inf,
        start = 0)
end
