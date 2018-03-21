export run_tfopf, run_ac_tfopf, run_dc_tfopf

""
function run_ac_tfopf(file, solver; kwargs...)
    return run_tfopf(file, ACPPowerModel, solver; kwargs...)
end

""
function run_dc_tfopf(file, solver; kwargs...)
    return run_tfopf(file, DCPPowerModel, solver; kwargs...)
end

""
function run_tfopf(file, model_constructor, solver; kwargs...)
    return run_generic_model(file, model_constructor, solver, post_tfopf; solution_builder = get_solution_tf, kwargs...)
end

""
function post_tfopf(pm::GenericPowerModel)
    PowerModels.variable_voltage(pm)
    PowerModels.variable_generation(pm)
    PowerModels.variable_branch_flow(pm) #d
    PowerModels.variable_dcline_flow(pm)
    variable_transformation(pm)

    PowerModels.objective_min_fuel_cost(pm)

    PowerModels.constraint_voltage(pm)
    for i in PowerModels.ids(pm, :ref_buses)
        PowerModels.constraint_theta_ref(pm, i)
    end

    for i in PowerModels.ids(pm, :bus)
        PowerModels.constraint_kcl_shunt(pm, i)
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
