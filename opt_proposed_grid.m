function [bestXi, bestZeta, bestRi, bestRj, bestSum, bestMin, bestJain] = ...
    opt_proposed_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList, zetaList)
%OPT_PROPOSED_GRID Joint grid search over xi and zeta.

bestSum = -inf;
bestXi = xiList(1);
bestZeta = zetaList(1);
bestRi = 0;
bestRj = 0;
bestMin = 0;
bestJain = 0;

for ix = 1:numel(xiList)
    for iz = 1:numel(zetaList)
        xi = xiList(ix);
        zeta = zetaList(iz);
        [~, ~, ~, rateRi, rateRj, sumRate, maxMinRate, jain] = ...
            calc_rates(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, xi, zeta, alpha, noiseVar);

        if sumRate > bestSum
            bestSum = sumRate;
            bestXi = xi;
            bestZeta = zeta;
            bestRi = rateRi;
            bestRj = rateRj;
            bestMin = maxMinRate;
            bestJain = jain;
        end
    end
end

end
