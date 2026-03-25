function res = sweep_power(cfg)
%SWEEP_POWER Sweep source power and average optimized metrics.

nP = numel(cfg.psDbmList);
nS = numel(cfg.schemeList);

avgSum = zeros(nP, nS);
avgRi = zeros(nP, nS);
avgRj = zeros(nP, nS);
avgMin = zeros(nP, nS);
avgJain = zeros(nP, nS);
avgXi = zeros(nP, nS);
avgZeta = zeros(nP, nS);

perMC = struct();

for ip = 1:nP
    ps = power_dbm_to_watt(cfg.psDbmList(ip));

    mcSum = zeros(cfg.numMC, nS);
    mcRi = zeros(cfg.numMC, nS);
    mcRj = zeros(cfg.numMC, nS);
    mcMin = zeros(cfg.numMC, nS);
    mcJain = zeros(cfg.numMC, nS);
    mcXi = zeros(cfg.numMC, nS);
    mcZeta = zeros(cfg.numMC, nS);

    for imc = 1:cfg.numMC
        chan = sample_rayleigh_channels();

        s1 = opt_proposed_grid(chan, ps, cfg.alphaDefault, cfg.noiseVar, cfg.xiList, cfg.zetaList);
        s2 = opt_benchmark_grid(chan, ps, cfg.alphaDefault, cfg.noiseVar, cfg.xiList, cfg.zetaFixed);
        s3 = opt_pure_noma_grid(chan, ps, cfg.alphaDefault, cfg.noiseVar, cfg.xiList);
        sols = {s1, s2, s3};

        for is = 1:nS
            s = sols{is};
            mcSum(imc, is) = s.sumRate;
            mcRi(imc, is) = s.rateRi;
            mcRj(imc, is) = s.rateRj;
            mcMin(imc, is) = s.maxMinRate;
            mcJain(imc, is) = s.jain;
            mcXi(imc, is) = s.xi;
            mcZeta(imc, is) = s.zeta;
        end
    end

    avgSum(ip, :) = mean(mcSum, 1);
    avgRi(ip, :) = mean(mcRi, 1);
    avgRj(ip, :) = mean(mcRj, 1);
    avgMin(ip, :) = mean(mcMin, 1);
    avgJain(ip, :) = mean(mcJain, 1);
    avgXi(ip, :) = mean(mcXi, 1);
    avgZeta(ip, :) = mean(mcZeta, 1);

    key = matlab.lang.makeValidName(sprintf('ps_%ddBm', cfg.psDbmList(ip)));
    perMC.(key).sumRate = mcSum;
    perMC.(key).rateRi = mcRi;
    perMC.(key).rateRj = mcRj;
    perMC.(key).maxMinRate = mcMin;
    perMC.(key).jain = mcJain;
    perMC.(key).xi = mcXi;
    perMC.(key).zeta = mcZeta;

    fprintf('[Power] %d dBm finished.\n', cfg.psDbmList(ip));
end

res.avgSumRate = avgSum;
res.avgRiRate = avgRi;
res.avgRjRate = avgRj;
res.avgMaxMinRate = avgMin;
res.avgJainFairness = avgJain;
res.avgOptXi = avgXi;
res.avgOptZeta = avgZeta;
res.perMC = perMC;

end
