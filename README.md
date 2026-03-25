# MATLAB Baseline Reproduction

## Folder split (by area)
- `opt/` : optimization solvers (`opt_p`, `opt_b`, `opt_n`)
- `noma/`: channel/rate/sweep (`ch`, `rates`, `swp_p`, `swp_a`, `p2w`)
- `pt/`  : plotting/table/save (`plt_p`, `plt_a`, `tbl`, `save_o`)
- `oma/` : OMA stub (`oma`)
- `cfg/` : defaults (`params`)

## Run
```matlab
run_main_repro
```
or
```matlab
main
```

## Outputs (`out/`)
- `fig_sumrate_power.png`, `fig_sumrate_power.fig`
- `fig_sumrate_alpha.png`, `fig_sumrate_alpha.fig`
- `res_power.csv`
- `res_alpha.csv`
- `all_results.mat`
