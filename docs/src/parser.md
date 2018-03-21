# File IO

```@meta
CurrentModule = PowerModelsReliability
```

## Specific Data Formats
The .m matpower files have been extended with the following fields:

### SCOPF

- `mpc.gen_rated.prated` rated active power of generator
- `mpc.gen_rated.qrated` rated reactive power of generator
- `mpc.gen_rated.pref`  reference active power set point of generator
- `mpc.gen_rated.qref`  reference reactive power set point of generator
- `mpc.load.load_bus` bus to which load is connected
- `mpc.load.pref` reference active power value of load
- `mpc.load.qref` reference reactive power value of load
- `mpc.load.status` reference status of load
- `mpc.load.qmax` reactive power maximum of load
- `mpc.load.qmin` reactive power minimum of load
- `mpc.load.pmax` active power maximum of load
- `mpc.load.pmin` active power minimum of load
- `mpc.load.prated` rated active power of load
- `mpc.load.qrated` rated reactive power of load
- `mpc.load.voll` value of lost load
- `mpc.branch_variable_transformer.g_shunt` conductive shunt of transformer
- `mpc.branch_variable_transformer.shiftable` is transformer shiftable?
- `mpc.branch_variable_transformer.shift_fr` shift set point at from side
- `mpc.branch_variable_transformer.shift_to` shift set point at to side
- `mpc.branch_variable_transformer.shift_fr_max` maximum shift set point at from side
- `mpc.branch_variable_transformer.shift_fr_min` minimum shift set point at from side
- `mpc.branch_variable_transformer.shift_to_max` maximum shift set point at to side
- `mpc.branch_variable_transformer.shift_to_min` minimum shift set point at to side
- `mpc.branch_variable_transformer.tappable` is transformer tappable?
- `mpc.branch_variable_transformer.tap_fr` tap setting at from side
- `mpc.branch_variable_transformer.tap_to` tap setting at to side
- `mpc.branch_variable_transformer.tap_fr_max` maximum tap setting at from side
- `mpc.branch_variable_transformer.tap_fr_min` minimum tap setting at from side
- `mpc.branch_variable_transformer.tap_to_max` maximum tap setting at to side
- `mpc.branch_variable_transformer.tap_to_min` minimum tap setting at to side
- `mpc.contingencies.prob` probability of contingency c
- `mpc.contingencies.branch_id1` id of first branch involved in contingency c, otherwise 0 if not involved
- `mpc.contingencies.branch_id2` id of second branch involved in contingency c, otherwise 0 if not involved
- `mpc.contingencies.branch_id3` id of third branch involved in contingency c, otherwise 0 if not involved
- `mpc.contingencies.gen_id1` id of first generator involved in contingency c, otherwise 0 if not involved
- `mpc.contingencies.gen_id2` id of second generator involved in contingency c, otherwise 0 if not involved
- `mpc.contingencies.gen_id3` id of third generator involved in contingency c, otherwise 0 if not involved
