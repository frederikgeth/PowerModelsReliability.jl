using PowerModelsReliability
using PowerModels
using InfrastructureModels
using Ipopt
using Mosek
using Juniper
using Cbc
using CPLEX

mosek = MosekSolver()
ipopt = IpoptSolver()
juniper = JuniperSolver(IpoptSolver(print_level=0); mip_solver=CplexSolver())

data_tf = PowerModels.parse_file("./test/data/case5_tf.m")
data_tf["multinetwork"] = false
resultACtf = run_tfopf(data_tf, ACPPowerModel, ipopt; multinetwork=false, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => true))
data_tf = PowerModels.parse_file("./test/data/case5_tf.m")
data_tf["multinetwork"] = false
resultDCtf = run_tfopf(data_tf, DCPPowerModel, ipopt; multinetwork=false, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => true))
