# AmBC_RSMA MATLAB Framework

You asked to group files by the first word prefix.
This version is organized as:

- `AmBC_RSMA.m` : main script entry
- `run_medium.m`, `run_full.m` : mode wrappers
- `run_pack.m` : all `run_*` family grouped
- `solve_pack.m` : solve router
- `noma_baseline_pack.m` : NOMA baseline role module
- `rsma_proposed_pack.m` : RSMA proposed role module
- `apply_pack.m` : channel generation + impairment application
- `calc_pack.m` : metric / gain / table helpers
- `plot_pack.m` : all plot helpers
- `save_pack.m` : output save pipeline
- `get_pack.m` : medium/full parameter policy
- `core_ch.m` : shared channel generation
- `core_rates.m` : NOMA baseline 2-user rates
- `core_rates_rsma.m` : RSMA 2-user rates

## Role split
- NOMA baseline path: `pure_noma`, `noma_fixed`, `noma_opt` -> `noma_baseline_pack.m`
- RSMA proposed path: `pure_rsma`, `rsma_fixed`, `rsma_opt` -> `rsma_proposed_pack.m`
- RSMA signal model in `core_rates_rsma.m`:
  `x = sqrt(Pc)*sc + sqrt(P1)*s1 + sqrt(P2)*s2`, with `Pc + P1 + P2 = Ps`.

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
