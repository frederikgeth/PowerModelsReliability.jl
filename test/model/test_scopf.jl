using PowerModelsReliability
using PowerModels
using InfrastructureModels
using Ipopt
using Mosek
using Juniper
using Cbc
using CPLEX
using Gurobi
using JuMP
using SCS

scs = JuMP.with_optimizer(SCS.Optimizer, max_iters=100000)
ipopt = JuMP.with_optimizer(Ipopt.Optimizer, tol=1e-6, print_level=0)

cplex = JuMP.with_optimizer(CPLEX.Optimizer)
cbc = JuMP.with_optimizer(Cbc.Optimizer)
gurobi = JuMP.with_optimizer(Gurobi.Optimizer)
mosek = JuMP.with_optimizer(Mosek.Optimizer)


juniper = JuMP.with_optimizer(Juniper.Optimizer, nl_solver = ipopt, mip_solver= cbc, time_limit= 7200)

function build_mn_data(base_data)
    mp_data = PowerModels.parse_file(base_data)
    mp_data["load"] = mp_data["sc_load"]
    n_cont = length(mp_data["contingencies"])
    return InfrastructureModels.replicate(mp_data, n_cont)
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

data = build_mn_data("./test/data/case5_scopf.m")
resultAC_rc = run_scunittfopf(data, ACPPowerModel, ipopt; multinetwork=true, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => true, "relax_absolute_value" => true))
data = build_mn_data("./test/data/case5_scopf.m")
resultAC = run_scunittfopf(data, ACPPowerModel, juniper; multinetwork=true, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => false, "relax_absolute_value" => true))
data = build_mn_data("./test/data/case5_scopf.m")
resultDC_rc = run_scunittfopf(data, DCPPowerModel, cplex; multinetwork=true, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => true, "relax_absolute_value" => false))
data = build_mn_data("./test/data/case5_scopf.m")
resultDC = run_scunittfopf(data, DCPPowerModel, cplex; multinetwork=true, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => false, "relax_absolute_value" => false))


# ,"relax_absolute_value" => true
#TODO
# Fixes to make everything compatible
# Extend data model with HVDC contingencies (Branch + Converter)
# Extend load shedding model to possible DC loads
# Start addig contingency constraints for the DC branches and converter models (first check on paper for issues such voltage etc, get inspiration from transformer model)
#
