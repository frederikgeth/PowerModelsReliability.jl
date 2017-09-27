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
    variable_action_indicator(pm)
    variable_auxiliary_power(pm)

    objective_min_redispatch_cost(pm)

    PowerModels.constraint_voltage(pm)
    for i in PowerModels.ids(pm, :ref_buses)
        PowerModels.constraint_theta_ref(pm, i)
    end

    for i in PowerModels.ids(pm, :bus)
        constraint_kcl_shunt_aggregated(pm, i)
        constraint_load_gen_aggregation_sheddable(pm, i)
    end

    for i in PowerModels.ids(pm, :load)
        constraint_flexible_load(pm, i)
        constraint_redispatch_power_load(pm, i)
    end

    for i in PowerModels.ids(pm, :gen)
        constraint_flexible_gen(pm, i)
        constraint_redispatch_power_gen(pm, i)
    end

    for i in PowerModels.ids(pm, :branch)
        branch = PowerModels.ref(pm, :branch, i)

        if branch["shiftable"] == false && branch["tappable"] == false
            PowerModels.constraint_ohms_yt_from(pm, i)
            PowerModels.constraint_ohms_yt_to(pm, i)
            constraint_link_voltage_magnitudes(pm, i)
        else
            constraint_variable_transformer_y_from(pm, i)
            constraint_variable_transformer_y_to(pm, i)
        end
        PowerModels.constraint_voltage_angle_difference(pm, i)

        PowerModels.constraint_thermal_limit_from(pm, i)
        PowerModels.constraint_thermal_limit_to(pm, i)
    end
    for i in PowerModels.ids(pm, :dcline)
        PowerModels.constraint_dcline(pm, i)
    end
end
