# PowerModelsReliability.jl

PowerModelsReliability.jl is a Julia/JuMP/PowerModels package with extensions for reliability management based on security-constrained OPF.
Building upon  PowerModels, the code is engineered to decouple problem specifications (e.g. Power Flow, Optimal Power Flow, ...) from the power network formulations (e.g. AC, DC-approximation, SOC-relaxation, ...).

**Core Problem Specifications**
* Optimal Power Flow with Phase Shifting Transformers and On-line Tap Changing Transformers (tfopf)
* Optimal Power Flow with Phase Shifting Transformers and On-line Tap Changing Transformers and Load Shedding (unittfopf)
* Security-Constrained Optimal Power Flow with Phase Shifting Transformers and On-line Tap Changing Transformers and Load Shedding (scunittfopf)


**Core Network Formulations**
* See PowerModels documentation

**Network Data Formats**
* Matpower ".m" files

For further information, consult the PowerModels [documentation](https://lanl-ansi.github.io/PowerModels.jl/stable/).


## Acknowledgments

The developers thank Carleton Coffrin for his support

## License

This code is provided under a BSD license.
