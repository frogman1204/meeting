# AmBC_RSMA MATLAB Framework

As requested, all `run_*` logic is grouped into a single file: `run.m`.

## Run modes
- `research_rsma` (default workflow): includes NOMA + RSMA schemes and keeps max-min oriented optimization behavior.
- `paper_reproduction`: paper-style NOMA-AmBC baseline reproduction with sum-rate-first objective.

You can run either from MATLAB:
```matlab
run('research_rsma')
run('paper_reproduction')
```

Legacy presets still work:
```matlab
run('medium')
run('full')
run('debug')
```
`medium/full/debug` map to the `research_rsma` experiment mode.

## Paper reproduction settings
`get_pack('paper_reproduction')` uses:
- `numMC = 1000`
- `Pt_dBm_vec = 10:3:40`
- `sic_err_vec = 0.1:0.1:0.9`
- `xi_grid = 0.02:0.02:0.5`
- `rho_grid = 0:0.02:1`
- `rho_fixed = 0.5`
- `sigma2 = 0.1`
- `rng_seed = 1`
- harvesting disabled (`harvest_cfg.enable = false`)

Paper-mode schemes:
- Proposed NOMA-AmBC (optimize `xi` and `rho`)
- Benchmark NOMA-AmBC (optimize `xi`, fixed `rho`)
- Pure NOMA
- OMA-AmBC

Paper-mode output CSV names:
- `tbl_power_paper.csv`
- `tbl_sic_paper.csv`

## OMA-AmBC assumption
`paper_reproduction` uses a true OMA-AmBC baseline: two orthogonal slots (`1/2` prelog per user), no inter-user interference, source power `Pt` in each active slot, and effective user gain `direct + backscatter` (no extra combining gain).

## Structure
- `main.m` : execution entry script
- `run.m` : all run pipeline logic (core, sweeps, summary)
- `solve_pack.m` : solve router
- `noma_baseline_pack.m` : NOMA/OMA baseline role module
- `rsma_proposed_pack.m` : RSMA proposed role module
- `apply_pack.m` : channel generation + impairment application
- `calc_pack.m` : metric / gain / table helpers
- `plot_pack.m` : plot helpers
- `save_pack.m` : output save pipeline
- `get_pack.m` : parameter policy / experiment modes
- `core.m` : channel/rate core formulas


Paper-mode figures:
- Sum-rate vs transmit power
- Sum-rate vs SIC error
(Other max-min / CSI / blockage / rho / RSMA diagnostic figures are intentionally suppressed in `paper_reproduction`.)


For `research_rsma`, the main fairness comparison uses max-min rate across six families: Pure OMA, OMA-AmBC, Pure NOMA, NOMA-AmBC, Pure RSMA, RSMA-AmBC.

Unified validation pack:
```matlab
validate_pack('research_rsma', 30)
validate_pack('paper_reproduction', 40)
validate_pack('guarded')
```
