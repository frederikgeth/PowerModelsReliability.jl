function add_load_model!(pm::GenericPowerModel, n::Int)
    bus_loads = Dict([(i, []) for i in PowerModels.ids(pm, n,:bus)])
     for (i,load) in PowerModels.ref(pm, n,:load)
        push!(bus_loads[load["load_bus"]], i)
     end
     pm.ref[:nw][n][:bus_loads] = bus_loads

end
add_load_model!(pm::GenericPowerModel) = add_load_model!(pm::GenericPowerModel, pm.cnw)
