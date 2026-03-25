function res = sweep_alpha(cfg)
%SWEEP_ALPHA Sweep imperfect SIC alpha and average optimized metrics.

nA = numel(cfg.alphaList);
nS = numel(cfg.schemeList);
ps = power_dbm_to_watt(cfg.psDbmDefault);

avgSum = zeros(nA, nS);
avgRi = zeros(nA, nS);
avgRj = zeros(nA, nS);
avgMin = zeros(nA, nS);
avgJain = zeros(nA, nS);
avgXi = zeros(nA, nS);
avgZeta = zeros(nA, nS);

perMC = struct();

for ia = 1:nA
    alpha = cfg.alphaList(ia);

    mcSum = zeros(cfg.numMC, nS);
    mcRi = zeros(cfg.numMC, nS);
    mcRj = zeros(cfg.numMC, nS);
    mcMin = zeros(cfg.numMC, nS);
    mcJain = zeros(cfg.numMC, nS);
    mcXi = zeros(cfg.numMC, nS);
    mcZeta = zeros(cfg.numMC, nS);

    for imc = 1:cfg.numMC
        chan = sample_rayleigh_channels();

        s1 = opt_proposed_grid(chan, ps, alpha, cfg.noiseVar, cfg.xiList, cfg.zetaList);
        s2 = opt_benchmark_grid(chan, ps, alpha, cfg.noiseVar, cfg.xiList, cfg.zetaFixed);
        s3 = opt_pure_noma_grid(chan, ps, alpha, cfg.noiseVar, cfg.xiList);
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

    avgSum(ia, :) = mean(mcSum, 1);
    avgRi(ia, :) = mean(mcRi, 1);
    avgRj(ia, :) = mean(mcRj, 1);
    avgMin(ia, :) = mean(mcMin, 1);
    avgJain(ia, :) = mean(mcJain, 1);
    avgXi(ia, :) = mean(mcXi, 1);
    avgZeta(ia, :) = mean(mcZeta, 1);

    key = matlab.lang.makeValidName(sprintf('alpha_%0.1f', alpha));
    perMC.(key).sumRate = mcSum;
    perMC.(key).rateRi = mcRi;
    perMC.(key).rateRj = mcRj;
    perMC.(key).maxMinRate = mcMin;
    perMC.(key).jain = mcJain;
    perMC.(key).xi = mcXi;
    perMC.(key).zeta = mcZeta;

    fprintf('[Alpha] %.1f finished.\n', alpha);
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
