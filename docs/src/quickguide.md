# Quick Start Guide

Once PowerModelsReliability is installed, Ipopt is installed, and a network data file (e.g. `"nesta_case3_lmbd.m"`) has been acquired, an AC Optimal Power Flow can be executed with,

```julia
using PowerModelsReliability
using Ipopt

run_ac_scopf("nesta_case3_lmbd.m", IpoptSolver())
```

## Modifying settings
The flow AC and DC branch results are not written to the result by default. To inspect the flow results, pass a settings Dict
```julia
result = run_opf("case3_dc.m", ACPPowerModel, IpoptSolver(), setting = Dict("output" => Dict("branch_flows" => true)))
result["solution"]["dcline"]["1"]
result["solution"]["branch"]["2"]
```
