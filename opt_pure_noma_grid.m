function best = opt_pure_noma_grid(chan, ps, alpha, noiseVar, xiList)
%OPT_PURE_NOMA_GRID Grid search xi for pure PD-NOMA (zeta=0).

best = opt_benchmark_grid(chan, ps, alpha, noiseVar, xiList, 0);

end
