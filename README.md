# AmBC_RSMA MATLAB Framework

As requested, all `run_*` logic is now grouped into a single file: `run.m`.
The script you execute is `main.m`.

## Current structure (prefix-grouped)
- `main.m` : execution entry script
- `run.m` : all run pipeline logic (`core`, sweeps, summary)
- `solve_pack.m` : solve router
- `opt.m` : grouped optimizer/benchmark/RSMA optimization helpers
- `noma_baseline_pack.m` : NOMA baseline role module
- `rsma_proposed_pack.m` : RSMA proposed role module
- `apply_pack.m` : channel generation + impairment application
- `calc_pack.m` : metric / gain / table helpers
- `plot_pack.m` : all plot helpers
- `save_pack.m` : output save pipeline
- `get_pack.m` : medium/full parameter policy
- `core.m` : grouped channel/rate/rate_rsma core formulas

## Run
```matlab
main
```
or
```matlab
main('full')
```

## File change summary
- Newly added in this update:
  - `run.m`, `core.m`, `opt.m`
- Removed in this update:
  - `AmBC_RSMA.m`, `run_medium.m`, `run_full.m`, `run_pack.m`
  - `core_ch.m`, `core_rates.m`, `core_rates_rsma.m`
  - `opt_p.m`, `opt_b.m`, `opt_rsma_power.m`, `opt_rsma_power_zeta.m`
- Modified in this update:
  - `main.m`, `README.md`
