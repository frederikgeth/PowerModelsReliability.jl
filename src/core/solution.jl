""
function get_solution_tf(pm::GenericPowerModel)
    sol = PowerModels.init_solution(pm)
    PowerModels.add_bus_voltage_setpoint(sol, pm)
    PowerModels.add_generator_power_setpoint(sol, pm)
    PowerModels.add_branch_flow_setpoint(sol, pm)
    PowerModels.add_dcline_flow_setpoint(sol, pm)
    add_branch_shift_setpoint(sol, pm)
    add_branch_tap_setpoint(sol, pm)
    return sol
end

""
function add_branch_shift_setpoint(sol, pm::GenericPowerModel)
  PowerModels.add_setpoint(sol, pm, "branch", "shiftf", :va_shift; extract_var = (var,idx,item) -> var[(idx, item["f_bus"], item["t_bus"])], default_value = (item) -> 0)
  PowerModels.add_setpoint(sol, pm, "branch", "shiftt", :va_shift; extract_var = (var,idx,item) -> var[(idx, item["t_bus"], item["f_bus"])], default_value = (item) -> 0)
end

""
function add_branch_tap_setpoint(sol, pm::GenericPowerModel)
    dict_name = "branch"
    index_name = "index"
    sol_dict = get(sol, dict_name, Dict{String,Any}())
    if length(pm.data[dict_name]) > 0
        sol[dict_name] = sol_dict
    end
    for (i,item) in pm.data[dict_name]
        idx = Int(item[index_name])
        fbus = Int(item["f_bus"])
        tbus = Int(item["t_bus"])
        sol_item = sol_dict[i] = get(sol_dict, i, Dict{String,Any}())
        sol_item["tapf"] = 1
        sol_item["tapt"] = 1
        try
            extract_vtap_fr = (var,idx,item) -> var[(idx, item["f_bus"], item["t_bus"])]
            extract_vtap_to = (var,idx,item) -> var[(idx, item["t_bus"], item["f_bus"])]
            vtap_fr = getvalue(extract_vtap_fr(pm.var[:vm_tap], idx, item))
            vtap_to = getvalue(extract_vtap_to(pm.var[:vm_tap], idx, item))
            vf = getvalue(pm.var[:vm])[fbus]
            vt = getvalue(pm.var[:vm])[tbus]
            sol_item["tapf"] = vf / vtap_fr
            sol_item["tapt"] = vt / vtap_to
        catch
        end
    end
end
