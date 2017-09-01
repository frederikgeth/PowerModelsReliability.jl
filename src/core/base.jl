function add_load_model!(pm)
    bus_loads = Dict([(i, []) for i in PowerModels.ids(pm,:bus)])
     for (i,load) in PowerModels.ref(pm,:load)
        push!(bus_loads[load["load_bus"]], i)

     end
     pm.ref[:nw][pm.cnw][:bus_loads] = bus_loads

end
