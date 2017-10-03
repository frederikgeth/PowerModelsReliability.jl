""
function get_solution_tf(pm::GenericPowerModel, sol::Dict{String,Any})
    PowerModels.add_bus_voltage_setpoint(sol, pm)
    PowerModels.add_generator_power_setpoint(sol, pm)
    PowerModels.add_branch_flow_setpoint(sol, pm)
    PowerModels.add_dcline_flow_setpoint(sol, pm)
    add_risk(sol, pm)
    add_branch_shift_setpoint(sol, pm)
    add_branch_tap_setpoint(sol, pm)
    add_load_power_setpoint(sol, pm)
    add_nodal_power_setpoint(sol, pm)
    add_pdelta(sol, pm)
    add_qdelta(sol, pm)
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
    if pm.data["multinetwork"] == false
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
                vtap_fr = getvalue(extract_vtap_fr(PowerModels.var(pm, :vm_tap), idx, item))
                vtap_to = getvalue(extract_vtap_to(PowerModels.var(pm, :vm_tap), idx, item))
                vf = getvalue(PowerModels.var(pm,:vm))[fbus]
                vt = getvalue(PowerModels.var(pm,:vm))[tbus]
                sol_item["tapf"] = vf / vtap_fr
                sol_item["tapt"] = vt / vtap_to
            catch
            end
        end
    else
        for (n,nw_data) in pm.data["nw"]
            sol_dict = get(sol, dict_name, Dict{String,Any}())
            if length(pm.data["nw"][n][dict_name]) > 0
                sol[dict_name] = sol_dict
            end
            for (i,item) in pm.data["nw"][n][dict_name]
                idx = Int(item[index_name])
                fbus = Int(item["f_bus"])
                tbus = Int(item["t_bus"])
                sol_item = sol_dict[i] = get(sol_dict, i, Dict{String,Any}())
                sol_item["tapf"] = 1
                sol_item["tapt"] = 1
                try
                    extract_vtap_fr = (var,idx,item) -> var[(idx, item["f_bus"], item["t_bus"])]
                    extract_vtap_to = (var,idx,item) -> var[(idx, item["t_bus"], item["f_bus"])]
                    vtap_fr = getvalue(extract_vtap_fr(PowerModels.var(pm, :vm_tap), idx, item))
                    vtap_to = getvalue(extract_vtap_to(PowerModels.var(pm, :vm_tap), idx, item))
                    vf = getvalue(PowerModels.var(pm,:vm))[fbus]
                    vt = getvalue(PowerModels.var(pm,:vm))[tbus]
                    sol_item["tapf"] = vf / vtap_fr
                    sol_item["tapt"] = vt / vtap_to
                catch
                end
            end
        end
    end
end

function add_load_power_setpoint(sol, pm::GenericPowerModel)
    mva_base = pm.data["baseMVA"]
    PowerModels.add_setpoint(sol, pm, "load", "pl", :pl)
    PowerModels.add_setpoint(sol, pm, "load", "ql", :ql)
end

function add_nodal_power_setpoint(sol, pm::GenericPowerModel)
    mva_base = pm.data["baseMVA"]
    PowerModels.add_setpoint(sol, pm, "bus", "pnode", :pnode)
    PowerModels.add_setpoint(sol, pm, "bus", "qnode", :qnode)
end

function add_pdelta(sol, pm::GenericPowerModel)
    mva_base = pm.data["baseMVA"]
    PowerModels.add_setpoint(sol, pm, "load", "pdelta", :pl_delta)
    PowerModels.add_setpoint(sol, pm, "gen", "pdelta", :pg_delta)
end

function add_qdelta(sol, pm::GenericPowerModel)
    mva_base = pm.data["baseMVA"]
    PowerModels.add_setpoint(sol, pm, "load", "qdelta", :ql_delta)
    PowerModels.add_setpoint(sol, pm, "gen", "qdelta", :qg_delta)
end

""
function add_risk(sol, pm::GenericPowerModel)
  add_case_level_setpoint(sol, pm, "first_stage_cost", :first_stage_cost)
  add_case_level_setpoint(sol, pm, "second_stage_risk", :second_stage_risk)
  add_nw_level_setpoint(sol, pm, "dispatch_cost", :dispatch_cost)
end


function add_case_level_setpoint(sol, pm::GenericPowerModel, param_name, variable_symbol; scale = (x) -> x, extract_var = var -> var)
        try
            variable = extract_var(pm.var[variable_symbol])
            sol[param_name] = scale(getvalue(variable))
        catch
        end
end


function add_nw_level_setpoint(sol, pm::GenericPowerModel, param_name, variable_symbol; scale = (x) -> x, extract_var = var -> var)
        try
                variable = extract_var(pm.var[variable_symbol][pm.cnw])
                sol[param_name] = scale(getvalue(variable))
        catch
        end
end
