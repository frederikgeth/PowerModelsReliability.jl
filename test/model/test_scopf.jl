using PowerModelsReliability
using PowerModels
using Ipopt
#using Mosek

#mosek = MosekSolver()
ipopt = IpoptSolver()

function build_mn_data(base_data)
    mp_data = PowerModels.parse_file(base_data)
    n_cont = length(mp_data["contingencies"])
    return PowerModels.replicate(mp_data, n_cont)
end

function build_mn_data(base_data_1, base_data_2)
    mp_data_1 = PowerModels.parse_file(base_data_1)
    mp_data_2 = PowerModels.parse_file(base_data_2)

    @assert mp_data_1["per_unit"] == mp_data_2["per_unit"]
    @assert mp_data_1["baseMVA"] == mp_data_2["baseMVA"]

    mn_data = Dict{String,Any}(
        "name" => "$(mp_data_1["name"]) + $(mp_data_2["name"])",
        "multinetwork" => true,
        "per_unit" => mp_data_1["per_unit"],
        "baseMVA" => mp_data_1["baseMVA"],
        "nw" => Dict{String,Any}()
    )

    delete!(mp_data_1, "multinetwork")
    delete!(mp_data_1, "per_unit")
    delete!(mp_data_1, "baseMVA")
    mn_data["nw"]["1"] = mp_data_1

    delete!(mp_data_2, "multinetwork")
    delete!(mp_data_2, "per_unit")
    delete!(mp_data_2, "baseMVA")
    mn_data["nw"]["2"] = mp_data_2

    return mn_data
end

data = build_mn_data("C:/Users/eheylen/.julia/v0.6/PowerModelsReliability/test/data/case5_scopf_load.m")
base_data = PowerModels.parse_file("C:/Users/eheylen/.julia/v0.6/PowerModelsReliability/test/data/case5_scopf.m")
display(data)
a = run_scunittfopf(data, ACPPowerModel, ipopt; multinetwork=true, setting = Dict("output" => Dict("line_flows" => true),"relax_continuous" => true))
display(a)
