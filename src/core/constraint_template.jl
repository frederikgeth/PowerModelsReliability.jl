""
function constraint_variable_transformer_y_from(pm::GenericPowerModel, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    branch = PowerModels.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = PowerModels.calc_branch_y(branch)
    c = branch["br_b"]
    g_shunt = branch["g_shunt"]
    tap_min = branch["tap_fr_min"]
    tap_max = branch["tap_fr_max"]

    return constraint_variable_transformer_y_from(pm, nw, cnd, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
end



""
function constraint_variable_transformer_y_to(pm::GenericPowerModel, i::Int;  nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    branch = PowerModels.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = PowerModels.calc_branch_y(branch)
    c = branch["br_b"]
    g_shunt = branch["g_shunt"]
    tap_min = branch["tap_to_min"]
    tap_max = branch["tap_to_max"]

    return constraint_variable_transformer_y_to(pm, nw, cnd, f_bus, t_bus, f_idx, t_idx, g, b, c, g_shunt, tap_min, tap_max)
end


""
function constraint_link_voltage_magnitudes(pm::GenericPowerModel, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    branch = PowerModels.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    tap_fr = branch["tap_fr"]
    tap_to = branch["tap_to"]

    return constraint_link_voltage_magnitudes(pm, nw, cnd, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to)
end

# function constraint_link_voltage_magnitudes(pm::GenericPowerModel, n::Int, i::Int)
#     branch = PowerModels.ref(pm, n, :branch, i)
#     f_bus = branch["f_bus"]
#     t_bus = branch["t_bus"]
#     f_idx = (i, f_bus, t_bus)
#     t_idx = (i, t_bus, f_bus)
#
#     tap_fr = branch["tap_fr"]
#     tap_to = branch["tap_to"]
#
#     return constraint_link_voltage_magnitudes(pm, n, f_bus, t_bus, f_idx, t_idx, tap_fr, tap_to)
# end
# constraint_link_voltage_magnitudes(pm::GenericPowerModel, i::Int) = constraint_link_voltage_magnitudes(pm::GenericPowerModel, pm.cnw, i::Int)


""
function constraint_kcl_shunt_aggregated(pm::GenericPowerModel, i::Int; nw::Int=pm.cnw, cnd::Int=pm.ccnd)
    bus = PowerModels.ref(pm, nw, :bus, i)
    bus_arcs = PowerModels.ref(pm, nw, :bus_arcs, i)
    bus_arcs_dc = PowerModels.ref(pm, nw, :bus_arcs_dc, i)

    bus_loads = ref(pm, nw, :bus_loads, i)
    bus_shunts = ref(pm, nw, :bus_shunts, i)

    bus_gs = Dict(k => ref(pm, nw, :shunt, k, "gs", cnd) for k in bus_shunts)
    bus_bs = Dict(k => ref(pm, nw, :shunt, k, "bs", cnd) for k in bus_shunts)

    return constraint_kcl_shunt_aggregated(pm, nw, cnd, i, bus_arcs, bus_arcs_dc, bus_gs, bus_bs)
end

""
function constraint_load_gen_aggregation(pm, nw::Int, i::Int)
        constraint_active_load_gen_aggregation(pm, nw, i)
        constraint_reactive_load_gen_aggregation(pm, nw, i)
end
constraint_load_gen_aggregation(pm::GenericPowerModel, i::Int) = constraint_load_gen_aggregation(pm::GenericPowerModel, pm.cnw, i::Int)


function constraint_active_load_gen_aggregation(pm, nw::Int, i::Int)
    bus = PowerModels.ref(pm, nw, :bus, i)
    bus_gens = PowerModels.ref(pm, nw, :bus_gens, i)

    return constraint_active_load_gen_aggregation(pm, nw, i, bus_gens, bus["pd"])
end
constraint_active_load_gen_aggregation(pm::GenericPowerModel, i::Int) = constraint_active_load_gen_aggregation(pm::GenericPowerModel, pm.cnw, i::Int)


function constraint_reactive_load_gen_aggregation(pm, nw::Int, i::Int)
    bus = PowerModels.ref(pm, nw, :bus, i)
    bus_gens = PowerModels.ref(pm, nw, :bus_gens, i)

    return constraint_reactive_load_gen_aggregation(pm, nw, i, bus_gens, bus["qd"])
end
constraint_reactive_load_gen_aggregation(pm::GenericPowerModel, i::Int) = constraint_reactive_load_gen_aggregation(pm::GenericPowerModel, pm.cnw, i::Int)


""
function constraint_load_gen_aggregation_sheddable(pm, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    constraint_active_load_gen_aggregation_sheddable(pm, nw, cnd, i)
    constraint_reactive_load_gen_aggregation_sheddable(pm, nw, cnd, i)
end
#constraint_load_gen_aggregation_sheddable(pm::GenericPowerModel, i::Int) = constraint_load_gen_aggregation_sheddable(pm::GenericPowerModel, pm.cnw, i::Int)

function constraint_active_load_gen_aggregation_sheddable(pm, nw::Int, cnd::Int, i::Int)
    bus = PowerModels.ref(pm, nw, :bus, i)
    bus_gens = PowerModels.ref(pm, nw, :bus_gens, i)
    bus_loads = PowerModels.ref(pm, nw, :bus_loads, i)

    return constraint_active_load_gen_aggregation_sheddable(pm, nw, cnd, i, bus_gens, bus_loads)
end
#constraint_active_load_gen_aggregation_sheddable(pm::GenericPowerModel, i::Int) = constraint_active_load_gen_aggregation_sheddable(pm::GenericPowerModel, pm.cnw, i::Int)


function constraint_reactive_load_gen_aggregation_sheddable(pm, nw::Int, cnd::Int, i::Int)
    bus = PowerModels.ref(pm, nw, :bus, i)
    bus_gens = PowerModels.ref(pm, nw, :bus_gens, i)
    bus_loads = PowerModels.ref(pm, nw, :bus_loads, i)

    return constraint_reactive_load_gen_aggregation_sheddable(pm, nw, cnd, i, bus_gens, bus_loads)
end
#constraint_reactive_load_gen_aggregation_sheddable(pm::GenericPowerModel, i::Int) = constraint_reactive_load_gen_aggregation_sheddable(pm::GenericPowerModel, pm.cnw, i::Int)

""
function constraint_flexible_load(pm, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
        constraint_flexible_active_load(pm, nw, cnd, i)
        constraint_flexible_reactive_load(pm, nw, cnd, i)
end

function constraint_flexible_active_load(pm, nw::Int, cnd::Int, i::Int)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_flexible_active_load(pm, nw, cnd, load["index"], load["prated"], load["pref"])
end

function constraint_flexible_reactive_load(pm, nw::Int, cnd::Int, i::Int)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_flexible_reactive_load(pm, nw, cnd, load["index"], load["qrated"], load["qref"])
end
# function constraint_flexible_load(pm::GenericPowerModel, n::Int, i::Int)
#         constraint_flexible_active_load(pm, n, i)
#         constraint_flexible_reactive_load(pm, n, i)
# end
# constraint_flexible_load(pm::GenericPowerModel, i::Int) = constraint_flexible_load(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_flexible_active_load(pm, n::Int, i::Int)
#     load = PowerModels.ref(pm, n, :load, i)
#     return constraint_flexible_active_load(pm, n, load["index"], load["prated"], load["pref"])
# end
# constraint_flexible_active_load(pm::GenericPowerModel, i::Int) = constraint_flexible_active_load(pm::GenericPowerModel, pm.cnw, i::Int)
#
#
# function constraint_flexible_reactive_load(pm, n::Int, i::Int)
#     load = PowerModels.ref(pm, n, :load, i)
#     return constraint_flexible_reactive_load(pm, n, load["index"], load["qrated"], load["qref"])
# end
# constraint_flexible_reactive_load(pm::GenericPowerModel, i::Int) = constraint_flexible_reactive_load(pm::GenericPowerModel, pm.cnw, i::Int)

""
function constraint_flexible_gen(pm, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
        constraint_flexible_active_gen(pm, nw, cnd, i)
        constraint_flexible_reactive_gen(pm, nw, cnd, i)
end

function constraint_flexible_active_gen(pm, nw::Int, cnd::Int, i::Int)
    gen = PowerModels.ref(pm, nw, :gen, i)
    return constraint_flexible_active_gen(pm, nw, cnd, gen["index"], gen["prated"], gen["pref"])
end

function constraint_flexible_reactive_gen(pm, nw::Int, cnd::Int, i::Int)
    gen = PowerModels.ref(pm, nw, :gen, i)
    return constraint_flexible_reactive_gen(pm, nw, cnd, gen["index"], gen["qrated"], gen["qref"])
end

# function constraint_flexible_gen(pm::GenericPowerModel, n::Int, i::Int)
#         constraint_flexible_active_gen(pm, n, i)
#         constraint_flexible_reactive_gen(pm, n, i)
# end
# constraint_flexible_gen(pm::GenericPowerModel, i::Int) = constraint_flexible_gen(pm::GenericPowerModel, pm.cnw, i::Int)
#
#
# function constraint_flexible_active_gen(pm, n::Int, i::Int)
#     gen = PowerModels.ref(pm, n, :gen, i)
#     return constraint_flexible_active_gen(pm, n, gen["index"], gen["prated"], gen["pref"])
# end
# constraint_flexible_active_gen(pm::GenericPowerModel, i::Int) = constraint_flexible_active_gen(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_flexible_reactive_gen(pm, n::Int, i::Int)
#     gen = PowerModels.ref(pm, n, :gen, i)
#     return constraint_flexible_reactive_gen(pm, n, gen["index"], gen["qrated"], gen["qref"])
# end
# constraint_flexible_reactive_gen(pm::GenericPowerModel, i::Int) = constraint_flexible_reactive_gen(pm::GenericPowerModel, pm.cnw, i::Int)

""
function constraint_redispatch_power_gen(pm, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    constraint_redispatch_active_power_gen(pm, nw, cnd, i)
    constraint_redispatch_reactive_power_gen(pm, nw, cnd, i)
end

function constraint_redispatch_active_power_gen(pm, nw::Int, cnd::Int, i::Int)
    gen = PowerModels.ref(pm, nw, :gen, i)
    return constraint_redispatch_active_power_gen(pm, nw, cnd, gen["index"], gen["pref"])
end

function constraint_redispatch_reactive_power_gen(pm, nw::Int, cnd::Int, i::Int)
    gen = PowerModels.ref(pm, nw, :gen, i)
    return constraint_redispatch_reactive_power_gen(pm, nw, cnd, gen["index"], gen["qref"])
end
#     constraint_redispatch_active_power_gen(pm, n::Int, i::Int)
#     constraint_redispatch_reactive_power_gen(pm, n::Int, i::Int)
# end
# constraint_redispatch_power_gen(pm::GenericPowerModel, i::Int) = constraint_redispatch_power_gen(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_redispatch_active_power_gen(pm, n::Int, i::Int)
#     gen = PowerModels.ref(pm, n, :gen, i)
#     return constraint_redispatch_active_power_gen(pm, n, gen["index"], gen["pref"])
# end
# constraint_redispatch_active_power_gen(pm::GenericPowerModel, i::Int) = constraint_redispatch_active_power_gen(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_redispatch_reactive_power_gen(pm, n::Int, i::Int)
#     gen = PowerModels.ref(pm, n, :gen, i)
#     return constraint_redispatch_reactive_power_gen(pm, n, gen["index"], gen["qref"])
# end
# constraint_redispatch_reactive_power_gen(pm::GenericPowerModel, i::Int) = constraint_redispatch_reactive_power_gen(pm::GenericPowerModel, pm.cnw, i::Int)
""
function constraint_second_stage_redispatch_power_gen(pm, nw::Int, i::Int, first_stage_network_id; cnd::Int = pm.ccnd)
    constraint_second_stage_redispatch_active_power_gen(pm, nw::Int, cnd::Int,  i::Int, first_stage_network_id)
    constraint_second_stage_redispatch_reactive_power_gen(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
end

function constraint_second_stage_redispatch_active_power_gen(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
    gen = PowerModels.ref(pm, nw, :gen, i)
    return constraint_second_stage_redispatch_active_power_gen(pm, nw, cnd, gen["index"], first_stage_network_id)
end

function constraint_second_stage_redispatch_reactive_power_gen(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
    gen = PowerModels.ref(pm, nw, :gen, i)
    return constraint_second_stage_redispatch_reactive_power_gen(pm, nw, cnd, gen["index"], first_stage_network_id)
end

# function constraint_second_stage_redispatch_power_gen(pm, n::Int, i::Int, first_stage_network_id)
#     constraint_second_stage_redispatch_active_power_gen(pm, n::Int, i::Int, first_stage_network_id)
#     constraint_second_stage_redispatch_reactive_power_gen(pm, n::Int, i::Int, first_stage_network_id)
# end
# constraint_second_stage_redispatch_power_gen(pm::GenericPowerModel, i::Int, first_stage_network_id) = constraint_second_stage_redispatch_power_gen(pm::GenericPowerModel, pm.cnw, i::Int, first_stage_network_id)
#
# function constraint_second_stage_redispatch_active_power_gen(pm, n::Int, i::Int, first_stage_network_id)
#     gen = PowerModels.ref(pm, n, :gen, i)
#     return constraint_second_stage_redispatch_active_power_gen(pm, n, gen["index"], first_stage_network_id)
# end
# constraint_second_stage_redispatch_active_power_gen(pm::GenericPowerModel, i::Int, first_stage_network_id) = constraint_second_stage_redispatch_active_power_gen(pm::GenericPowerModel, pm.cnw, i::Int, first_stage_network_id)
#
# function constraint_second_stage_redispatch_reactive_power_gen(pm, n::Int, i::Int, first_stage_network_id)
#     gen = PowerModels.ref(pm, n, :gen, i)
#     return constraint_second_stage_redispatch_reactive_power_gen(pm, n, gen["index"], first_stage_network_id)
# end
# constraint_second_stage_redispatch_reactive_power_gen(pm::GenericPowerModel, i::Int, first_stage_network_id) = constraint_second_stage_redispatch_reactive_power_gen(pm::GenericPowerModel, pm.cnw, i::Int, first_stage_network_id)

""
function constraint_redispatch_power_load(pm, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    constraint_redispatch_active_power_load(pm, nw::Int, cnd::Int, i::Int)
    constraint_redispatch_reactive_power_load(pm, nw::Int, cnd::Int, i::Int)
end

function constraint_redispatch_active_power_load(pm, nw::Int, cnd::Int, i::Int)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_redispatch_active_power_load(pm, nw, cnd, load["index"], load["pref"])
end

function constraint_redispatch_reactive_power_load(pm, nw::Int, cnd::Int, i::Int)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_redispatch_reactive_power_load(pm, nw, cnd, load["index"], load["qref"])
end
constraint_redispatch_reactive_power_load(pm::GenericPowerModel, i::Int) = constraint_redispatch_reactive_power_load(pm::GenericPowerModel, pm.cnw, i::Int)
""
function constraint_second_stage_redispatch_power_load(pm, nw::Int, i::Int, first_stage_network_id; cnd::Int = pm.ccnd)
    constraint_second_stage_redispatch_active_power_load(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
    constraint_second_stage_redispatch_reactive_power_load(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
    constraint_tan_phi_load(pm, nw::Int, cnd::Int, i::Int)
end

function constraint_second_stage_redispatch_active_power_load(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_second_stage_redispatch_active_power_load(pm, nw, cnd, load["index"], first_stage_network_id)
end

function constraint_second_stage_redispatch_reactive_power_load(pm, nw::Int, cnd::Int, i::Int, first_stage_network_id)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_second_stage_redispatch_reactive_power_load(pm, nw, cnd, load["index"], first_stage_network_id)
end

function constraint_tan_phi_load(pm, nw::Int, cnd::Int, i::Int)
    load_angle = PowerModels.ref(pm, nw, :load_angle, i)[1]
    return constraint_tan_phi_load(pm, nw, cnd, i, load_angle)
end

# function constraint_second_stage_redispatch_power_load(pm, n::Int, i::Int, first_stage_network_id)
#     constraint_second_stage_redispatch_active_power_load(pm, n::Int, i::Int, first_stage_network_id)
#     constraint_second_stage_redispatch_reactive_power_load(pm, n::Int, i::Int, first_stage_network_id)
#     constraint_tan_phi_load(pm, n::Int, i::Int)
# end
# constraint_second_stage_redispatch_power_load(pm::GenericPowerModel, i::Int, first_stage_network_id) = constraint_second_stage_redispatch_power_load(pm::GenericPowerModel, pm.cnw, i::Int, first_stage_network_id)
#
# function constraint_second_stage_redispatch_active_power_load(pm, n::Int, i::Int, first_stage_network_id)
#     load = PowerModels.ref(pm, n, :load, i)
#     return constraint_second_stage_redispatch_active_power_load(pm, n, load["index"], first_stage_network_id)
# end
# constraint_second_stage_redispatch_active_power_load(pm::GenericPowerModel, i::Int, first_stage_network_id) = constraint_second_stage_redispatch_active_power_load(pm::GenericPowerModel, pm.cnw, i::Int, first_stage_network_id)
#
# function constraint_second_stage_redispatch_reactive_power_load(pm, n::Int, i::Int, first_stage_network_id)
#     load = PowerModels.ref(pm, n, :load, i)
#     return constraint_second_stage_redispatch_reactive_power_load(pm, n, load["index"], first_stage_network_id)
# end
# constraint_second_stage_redispatch_reactive_power_load(pm::GenericPowerModel, i::Int, first_stage_network_id) = constraint_second_stage_redispatch_reactive_power_load(pm::GenericPowerModel, pm.cnw, i::Int, first_stage_network_id)
#
# function constraint_tan_phi_load(pm, n::Int, i::Int)
#     load_angle = PowerModels.ref(pm, n, :load_angle, i)[1]
#     return constraint_tan_phi_load(pm, n, i, load_angle)
# end
# constraint_tan_phi_load(pm::GenericPowerModel, i::Int) = constraint_tan_phi_load(pm::GenericPowerModel, pm.cnw, i::Int)

""
function constraint_fixed_load(pm, i::Int; nw::Int = pm.cnw, cnd::Int = pm.ccnd)
    constraint_fixed_active_load(pm, nw, cnd, i)
    constraint_fixed_reactive_load(pm, nw, cnd, i)
end

function constraint_fixed_active_load(pm, nw::Int, cnd::Int, i::Int)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_fixed_active_load(pm, nw, cnd, load["index"], load["pref"])
end

function constraint_fixed_reactive_load(pm, nw::Int, cnd::Int, i::Int)
    load = PowerModels.ref(pm, nw, :load, i)
    return constraint_fixed_reactive_load(pm, nw, cnd, load["index"], load["qref"])
end

# function constraint_fixed_load(pm::GenericPowerModel, n::Int, i::Int)
#     constraint_fixed_active_load(pm::GenericPowerModel, n::Int, i::Int)
#     constraint_fixed_reactive_load(pm::GenericPowerModel, n::Int, i::Int)
# end
# constraint_fixed_load(pm::GenericPowerModel, i::Int) = constraint_fixed_load(pm::GenericPowerModel, pm.cnw, i::Int)

# function constraint_fixed_active_load(pm, n::Int, i::Int)
#     load = PowerModels.ref(pm, n, :load, i)
#     return constraint_fixed_active_load(pm, n, load["index"], load["pref"])
# end
# constraint_fixed_active_load(pm::GenericPowerModel, i::Int) = constraint_fixed_active_load(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_fixed_reactive_load(pm, n::Int, i::Int)
#     load = PowerModels.ref(pm, n, :load, i)
#     return constraint_fixed_reactive_load(pm, n, load["index"], load["qref"])
# end
# constraint_fixed_reactive_load(pm::GenericPowerModel, i::Int) = constraint_fixed_reactive_load(pm::GenericPowerModel, pm.cnw, i::Int)

""
function constraint_gen_contingency(pm::GenericPowerModel, nw::Int, i::Int; cnd::Int = pm.ccnd)
    constraint_active_power_gen_contingency(pm::GenericPowerModel, nw::Int, cnd::Int, i::Int)
    constraint_reactive_power_gen_contingency(pm::GenericPowerModel, nw::Int, cnd::Int, i::Int)
end

# function constraint_gen_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     constraint_active_power_gen_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     constraint_reactive_power_gen_contingency(pm::GenericPowerModel, n::Int, i::Int)
# end
# constraint_gen_contingency(pm::GenericPowerModel, i::Int) = constraint_gen_contingency(pm::GenericPowerModel, pm.cnw, i::Int)

""
function constraint_branch_contingency(pm::GenericPowerModel, nw::Int, i::Int; cnd::Int = pm.ccnd)
    constraint_active_power_branch_contingency(pm::GenericPowerModel, nw::Int, cnd::Int, i::Int)
    constraint_reactive_power_branch_contingency(pm::GenericPowerModel, nw::Int, cnd::Int, i::Int)
end

function constraint_active_power_branch_contingency(pm::GenericPowerModel, nw::Int, cnd::Int, i::Int)
    branch = PowerModels.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    return constraint_active_power_branch_contingency(pm, nw, cnd, branch["index"], f_idx, t_idx)
end

function constraint_reactive_power_branch_contingency(pm::GenericPowerModel, nw::Int, cnd::Int, i::Int)
    branch = PowerModels.ref(pm, nw, :branch, i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    return constraint_reactive_power_branch_contingency(pm, nw, cnd,  branch["index"], f_idx, t_idx)
end

# function constraint_branch_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     constraint_active_power_branch_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     constraint_reactive_power_branch_contingency(pm::GenericPowerModel, n::Int, i::Int)
# end
# constraint_branch_contingency(pm::GenericPowerModel, i::Int) = constraint_branch_contingency(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_active_power_branch_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     branch = PowerModels.ref(pm, n, :branch, i)
#     f_bus = branch["f_bus"]
#     t_bus = branch["t_bus"]
#     f_idx = (i, f_bus, t_bus)
#     t_idx = (i, t_bus, f_bus)
#
#     return constraint_active_power_branch_contingency(pm, n, branch["index"], f_idx, t_idx)
# end
# constraint_active_power_branch_contingency(pm::GenericPowerModel, i::Int) = constraint_active_power_branch_contingency(pm::GenericPowerModel, pm.cnw, i::Int)
#
# function constraint_reactive_power_branch_contingency(pm::GenericPowerModel, n::Int, i::Int)
#     branch = PowerModels.ref(pm, n, :branch, i)
#     f_bus = branch["f_bus"]
#     t_bus = branch["t_bus"]
#     f_idx = (i, f_bus, t_bus)
#     t_idx = (i, t_bus, f_bus)
#
#     return constraint_reactive_power_branch_contingency(pm, n, branch["index"], f_idx, t_idx)
# end
# constraint_reactive_power_branch_contingency(pm::GenericPowerModel, i::Int) = constraint_reactive_power_branch_contingency(pm::GenericPowerModel, pm.cnw, i::Int)
