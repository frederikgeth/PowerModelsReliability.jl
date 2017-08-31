function add_load_model!(pm)
    bus_loads = Dict([(i, []) for (i,bus) in pm.ref[:bus]])
    for (i,load) in pm.ref[:load]
        push!(bus_loads[load["load_bus"]], i)
    end
    pm.ref[:bus_loads] = bus_loads
end
