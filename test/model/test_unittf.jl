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
data_tf["load"] = data_tf["tf_load"]
resultDCunittf = run_unittfopf(data_tf, DCPPowerModel, mosek; multinetwork=false, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => true))

data_tf = PowerModels.parse_file("./test/data/case5_tf.m")
data_tf["multinetwork"] = false
data_tf["load"] = data_tf["tf_load"]
resultACunittf = run_unittfopf(data_tf, ACPPowerModel, juniper; multinetwork=false, setting = Dict("output" => Dict("branch_flows" => true),"relax_continuous" => true))
