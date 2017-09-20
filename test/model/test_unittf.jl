using PowerModelsReliability
using PowerModels
using Ipopt
using Mosek

mosek = MosekSolver()
ipopt = IpoptSolver()

data = PowerModels.parse_file("C:/Users/hergun/.julia/v0.6/PowerModelsReliability/test/data/case5_tf.m")
display(data)
a = run_unittfopf(data, ACPPowerModel, ipopt; setting = Dict("output" => Dict("line_flows" => true),"relax_continuous" => true))
display(a)
