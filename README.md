# RSMA-AmBC Exploratory MATLAB Framework

## Entry points
- `run_medium.m` : medium mode only
- `run_full.m` : full mode only

Both call `run_all_figures_core(params, mode_name)` and save outputs automatically to timestamped folders:
- `out/medium_run_YYYYMMDD_HHMMSS/`
- `out/full_run_YYYYMMDD_HHMMSS/`

## Implemented schemes
1. Pure NOMA
2. NOMA-AmBC (Fixed rho)
3. NOMA-AmBC (Optimized rho)
4. Pure RSMA
5. RSMA-AmBC (Fixed rho)
6. RSMA-AmBC (Optimized rho)

## Notes
- OMA is intentionally excluded.
- Optimized versions optimize `rho` only via grid search in this version.
- BER is placeholder (`NaN`) with TODO comments.
