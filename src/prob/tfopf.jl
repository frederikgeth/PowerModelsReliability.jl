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
    PowerModels.variable_line_flow(pm)
    PowerModels.variable_dcline_flow(pm)
    variable_transformation(pm)

    PowerModels.objective_min_fuel_cost(pm)

    PowerModels.constraint_voltage(pm)
    for (i,bus) in pm.ref[:ref_buses]
        PowerModels.constraint_theta_ref(pm, bus)
    end

    for (i,bus) in pm.ref[:bus]
        PowerModels.constraint_kcl_shunt(pm, bus)
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
