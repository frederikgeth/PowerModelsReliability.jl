using PowerModelsReliability

using Logging
# suppress warnings during testing
Logging.configure(level=ERROR)

using JuMP
using PowerModels
PMs = PowerModels

using Ipopt

using Base.Test

# default setup for solvers
ipopt_solver = IpoptSolver(tol=1e-6, print_level=0)


# this will work because PowerModels is a dependency
case_files = [
    "../../PowerModelsReliability/test/data/case5_tf.m",
]

#include("prob/tfopf.jl")
