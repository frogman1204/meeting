# AmBC_RSMA MATLAB Framework

You asked to group files by the first word prefix.
This version is organized as:

- `AmBC_RSMA.m` : main script entry
- `run_medium.m`, `run_full.m` : mode wrappers
- `run_pack.m` : all `run_*` family grouped
- `solve_pack.m` : all `solve_*` family grouped
- `apply_pack.m` : channel generation + impairment application
- `calc_pack.m` : metric / gain / table helpers
- `plot_pack.m` : all plot helpers
- `save_pack.m` : output save pipeline
- `get_pack.m` : medium/full parameter policy

## Run
```matlab
run_medium
```
or
```matlab
run_full
```
or
```matlab
AmBC_RSMA('medium')
AmBC_RSMA('full')
```
