function [bestXi, bestZeta, bestRi, bestRj, bestSum, bestMin, bestJain] = ...
    opt_benchmark_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList, zetaFixed)
%OPT_BENCHMARK_GRID Grid search xi with fixed zeta.

bestSum = -inf;
bestXi = xiList(1);
bestZeta = zetaFixed;
bestRi = 0;
bestRj = 0;
bestMin = 0;
bestJain = 0;

for ix = 1:numel(xiList)
    xi = xiList(ix);
    [~, ~, ~, rateRi, rateRj, sumRate, maxMinRate, jain] = ...
        calc_rates(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, xi, zetaFixed, alpha, noiseVar);

    if sumRate > bestSum
        bestSum = sumRate;
        bestXi = xi;
        bestZeta = zetaFixed;
        bestRi = rateRi;
        bestRj = rateRj;
        bestMin = maxMinRate;
        bestJain = jain;
    end
end

end
