# PowerModelsReliability.jl Documentation

```@meta
CurrentModule = PowerModelsReliability
```

## Overview

PowerModelsReliability.jl is a Julia/JuMP package extending PowerModels.jl, which focuses on Steady-State Power Network Optimization. PowerModels.jl provides utilities for parsing and modifying network data and is designed to enable computational evaluation of emerging power network formulations and algorithms in a common platform.

PowerModelsReliability.jl adds new formulations and problem types:
- OPF with shiftable (PST) and tappable (OLTC) transformers `tfopf`
- OPF with shiftable (PST) and tappable (OLTC) transformers, and with load shedding `unittfopf`
- Two-stage SCOPF (generator and line contingencies) with shiftable (PST) and tappable (OLTC) transformers, and with load shedding `scunittfopf`


## Installation of PowerModelsReliability

The latest stable release of PowerModelsReliability can be installed using the Julia package manager with

```julia
Pkg.clone("https://github.com/frederikgeth/PowerModelsReliability.jl.git")
```

!!! note
    This is a research-grade optimization package. There may be issues with the code. Please consult the [issue tracker](https://github.com/frederikgeth/PowerModelsReliability.jl/issues) to get an overview of the open issues.
