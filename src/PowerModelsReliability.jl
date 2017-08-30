isdefined(Base, :__precompile__) && __precompile__()

module PowerModelsReliability

using Compat
using JuMP
using PowerModels
PMs = PowerModels

include("core/variable.jl")
include("core/constraint_template.jl")
include("core/solution.jl")
include("form/acp.jl")
include("form/dcp.jl")
include("prob/tfopf.jl")
end
