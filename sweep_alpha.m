function [avgSumRate, avgRiRate, avgRjRate, avgMaxMinRate, avgJainFairness, avgOptXi, avgOptZeta, perMcAlpha] = ...
    sweep_alpha(numMC, psDbmDefault, alphaList, schemeList, noiseVar, xiList, zetaList, zetaFixed)
%SWEEP_ALPHA Sweep imperfect SIC alpha and average optimized metrics.

nA = numel(alphaList);
nS = numel(schemeList);
ps = power_dbm_to_watt(psDbmDefault);

avgSumRate = zeros(nA, nS);
avgRiRate = zeros(nA, nS);
avgRjRate = zeros(nA, nS);
avgMaxMinRate = zeros(nA, nS);
avgJainFairness = zeros(nA, nS);
avgOptXi = zeros(nA, nS);
avgOptZeta = zeros(nA, nS);

perMcAlpha = cell(nA, 1);

for ia = 1:nA
    alpha = alphaList(ia);

    mcSum = zeros(numMC, nS);
    mcRi = zeros(numMC, nS);
    mcRj = zeros(numMC, nS);
    mcMin = zeros(numMC, nS);
    mcJain = zeros(numMC, nS);
    mcXi = zeros(numMC, nS);
    mcZeta = zeros(numMC, nS);

    for imc = 1:numMC
        [hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj] = sample_rayleigh_channels();

        [x1, z1, r1i, r1j, s1, m1, j1] = ...
            opt_proposed_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList, zetaList);
        [x2, z2, r2i, r2j, s2, m2, j2] = ...
            opt_benchmark_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList, zetaFixed);
        [x3, z3, r3i, r3j, s3, m3, j3] = ...
            opt_pure_noma_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList);

        mcSum(imc, :) = [s1 s2 s3];
        mcRi(imc, :) = [r1i r2i r3i];
        mcRj(imc, :) = [r1j r2j r3j];
        mcMin(imc, :) = [m1 m2 m3];
        mcJain(imc, :) = [j1 j2 j3];
        mcXi(imc, :) = [x1 x2 x3];
        mcZeta(imc, :) = [z1 z2 z3];
    end

    avgSumRate(ia, :) = mean(mcSum, 1);
    avgRiRate(ia, :) = mean(mcRi, 1);
    avgRjRate(ia, :) = mean(mcRj, 1);
    avgMaxMinRate(ia, :) = mean(mcMin, 1);
    avgJainFairness(ia, :) = mean(mcJain, 1);
    avgOptXi(ia, :) = mean(mcXi, 1);
    avgOptZeta(ia, :) = mean(mcZeta, 1);

    perMcAlpha{ia} = {mcSum, mcRi, mcRj, mcMin, mcJain, mcXi, mcZeta};

    fprintf('[Alpha] %.1f finished.\n', alpha);
end

end
