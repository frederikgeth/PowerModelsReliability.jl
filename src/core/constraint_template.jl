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

    tap_fr = branch["tap_fr"]
    tap_to = branch["tap_to"]

    return constraint_link_voltage_magnitudes(pm, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to)
end

""
function constraint_kcl_shunt_aggregated(pm, bus)
    i = bus["index"]
    bus_arcs = pm.ref[:bus_arcs][i]
    bus_arcs_dc = pm.ref[:bus_arcs_dc][i]

    return constraint_kcl_shunt_aggregated(pm, i, bus_arcs, bus_arcs_dc, bus["gs"], bus["bs"])
end

""
function contraint_load_gen_aggregation(pm, bus)
        contraint_active_load_gen_aggregation(pm, bus)
        contraint_reactive_load_gen_aggregation(pm, bus)
end

function contraint_active_load_gen_aggregation(pm, bus)
    i = bus["index"]
    bus_gens = pm.ref[:bus_gens][i]

    return contraint_active_load_gen_aggregation(pm, i, bus_gens, bus["pd"])
end

function contraint_reactive_load_gen_aggregation(pm, bus)
    i = bus["index"]
    bus_gens = pm.ref[:bus_gens][i]

    return contraint_reactive_load_gen_aggregation(pm, i, bus_gens, bus["qd"])
end

""
function contraint_load_gen_aggregation_sheddable(pm, bus)
    contraint_active_load_gen_aggregation_sheddable(pm, bus)
    contraint_reactive_load_gen_aggregation_sheddable(pm, bus)
end

function contraint_active_load_gen_aggregation_sheddable(pm, bus)
    i = bus["index"]
    bus_gens = pm.ref[:bus_gens][i]
    bus_loads = pm.ref[:bus_loads][i]

    return contraint_active_load_gen_aggregation_sheddable(pm, i, bus_gens, bus_loads)
end

function contraint_reactive_load_gen_aggregation_sheddable(pm, bus)
    i = bus["index"]
    bus_gens = pm.ref[:bus_gens][i]
    bus_loads = pm.ref[:bus_loads][i]

    return contraint_reactive_load_gen_aggregation_sheddable(pm, i, bus_gens, bus_loads)
end

""
function constraint_flexible_load(pm::GenericPowerModel, load)
        constraint_flexible_active_load(pm, load)
        constraint_flexible_reactive_load(pm, load)
end
function constraint_flexible_active_load(pm, load)
    return constraint_flexible_active_load(pm, load["index"], load["prated"], load["pref"])
end

function constraint_flexible_reactive_load(pm, load)
    return constraint_flexible_reactive_load(pm, load["index"], load["qrated"], load["qref"])
end

""
function constraint_flexible_gen(pm::GenericPowerModel, gen)
        constraint_flexible_active_gen(pm, gen)
        constraint_flexible_reactive_gen(pm, gen)
end

function constraint_flexible_active_gen(pm, gen)

    return constraint_flexible_active_gen(pm, gen["index"], gen["prated"], gen["pref"])
end

function constraint_flexible_reactive_gen(pm, gen)

    return constraint_flexible_reactive_gen(pm, gen["index"], gen["qrated"], gen["qref"])
end

""
function constraint_redispatch_power_gen(pm, gen)

    return constraint_redispatch_power_gen(pm, gen["index"], gen["pref"])
end

function constraint_redispatch_power_load(pm, load)

    return constraint_redispatch_power_load(pm, load["index"], load["pref"])
end
