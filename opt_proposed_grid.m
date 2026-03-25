function best = opt_proposed_grid(chan, ps, alpha, noiseVar, xiList, zetaList)
%OPT_PROPOSED_GRID Joint grid search over xi and zeta.

best.sumRate = -inf;
best.xi = xiList(1);
best.zeta = zetaList(1);
best.rateRi = 0;
best.rateRj = 0;
best.maxMinRate = 0;
best.jain = 0;

for ix = 1:numel(xiList)
    for iz = 1:numel(zetaList)
        xi = xiList(ix);
        zeta = zetaList(iz);
        met = calc_rates(chan, ps, xi, zeta, alpha, noiseVar);

        if met.sumRate > best.sumRate
            best.sumRate = met.sumRate;
            best.xi = xi;
            best.zeta = zeta;
            best.rateRi = met.rateRi;
            best.rateRj = met.rateRj;
            best.maxMinRate = met.maxMinRate;
            best.jain = met.jain;
        end
    end
end

end
