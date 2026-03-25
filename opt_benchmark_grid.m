function best = opt_benchmark_grid(chan, ps, alpha, noiseVar, xiList, zetaFixed)
%OPT_BENCHMARK_GRID Grid search xi with fixed zeta.

best.sumRate = -inf;
best.xi = xiList(1);
best.zeta = zetaFixed;
best.rateRi = 0;
best.rateRj = 0;
best.maxMinRate = 0;
best.jain = 0;

for ix = 1:numel(xiList)
    xi = xiList(ix);
    met = calc_rates(chan, ps, xi, zetaFixed, alpha, noiseVar);

    if met.sumRate > best.sumRate
        best.sumRate = met.sumRate;
        best.xi = xi;
        best.zeta = zetaFixed;
        best.rateRi = met.rateRi;
        best.rateRj = met.rateRj;
        best.maxMinRate = met.maxMinRate;
        best.jain = met.jain;
    end
end

end
