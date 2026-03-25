# MATLAB Baseline Reproduction (Single-File)

## Run
```matlab
run_main_repro
```
or
```matlab
main
```

## What it does
- Reproduces 3 baselines with grid search:
  - proposed joint-opt PD-NOMA AmBC (`xi`, `zeta` 2D grid)
  - benchmark PD-NOMA AmBC (`xi` 1D grid, fixed `zeta`)
  - pure PD-NOMA (`zeta=0`, `xi` 1D grid)
- Runs:
  - Sum-rate vs source power (`10:3:40` dBm)
  - Sum-rate vs imperfect SIC `alpha` (`0.1:0.1:0.9`, fixed `40` dBm)
- Saves outputs into `out/`:
  - `fig_sumrate_power.png/.fig`
  - `fig_sumrate_alpha.png/.fig`
  - `res_power.csv`
  - `res_alpha.csv`
  - `all_results.mat`

## Notes
- Main logic is intentionally merged into `main.m` to minimize file count.
- `main.m` contains local helper functions for channel generation, rates, optimization, sweeps, plotting, table build, and saving.
