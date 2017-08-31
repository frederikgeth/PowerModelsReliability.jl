export run_unittfopf, run_ac_unittfopf, run_dc_unittfopf

""
function run_ac_unittfopf(data, solver; kwargs...)
    return run_unittfopf(data, ACPPowerModel, solver; kwargs...)
end

""
function run_dc_unittfopf(data, solver; kwargs...)
    return run_unittfopf(data, DCPPowerModel, solver; kwargs...)
end

""
function run_unittfopf(data, model_constructor, solver; kwargs...)
    process_additional_data(data)
    pm = PowerModels.build_generic_model(data, model_constructor, post_unittfopf; kwargs...)
    return PowerModels.solve_generic_model(pm, solver; solution_builder = get_solution_tf)
end

""
function post_unittfopf(pm::GenericPowerModel)
    add_load_model!(pm) # To add load data
    PowerModels.variable_voltage(pm)
    PowerModels.variable_generation(pm)
    PowerModels.variable_line_flow(pm)
    PowerModels.variable_dcline_flow(pm)
    variable_transformation(pm)
    variable_node_aggregation(pm)
    variable_load(pm)
    #variable_action_indicator(pm)
    variable_auxiliary_power(pm)

    objective_min_redispatch_cost(pm)

    PowerModels.constraint_voltage(pm)
    for (i,bus) in pm.ref[:ref_buses]
        PowerModels.constraint_theta_ref(pm, bus)
    end

    for (i,bus) in pm.ref[:bus]
        constraint_kcl_shunt_aggregated(pm, bus)
        contraint_load_gen_aggregation_sheddable(pm, bus)
    end
    for (i,load) in pm.ref[:load]
        #constraint_flexible_load(pm, load)
        constraint_redispatch_power_load(pm, load)
    end

    for (i,gen) in pm.ref[:gen]
        #constraint_flexible_gen(pm, gen)
        constraint_redispatch_power_gen(pm, gen)
    end

    for (i,branch) in pm.ref[:branch]
        if branch["shiftable"] == false && branch["tappable"] == false
            PowerModels.constraint_ohms_yt_from(pm, branch)
            PowerModels.constraint_ohms_yt_to(pm, branch)
            constraint_link_voltage_magnitudes(pm, branch)
        else
            constraint_variable_transformer_y_from(pm, branch)
            constraint_variable_transformer_y_to(pm, branch)
        end
        PowerModels.constraint_voltage_angle_difference(pm, branch)

        PowerModels.constraint_thermal_limit_from(pm, branch)
        PowerModels.constraint_thermal_limit_to(pm, branch)
    end
    for (i,dcline) in pm.ref[:dcline]
        PowerModels.constraint_dcline(pm, dcline)
    end
end
