function [avgSumRate, avgRiRate, avgRjRate, avgMaxMinRate, avgJainFairness, avgOptXi, avgOptZeta, perMcPower] = ...
    sweep_power(numMC, psDbmList, schemeList, alphaDefault, noiseVar, xiList, zetaList, zetaFixed)
%SWEEP_POWER Sweep source power and average optimized metrics.

nP = numel(psDbmList);
nS = numel(schemeList);

avgSumRate = zeros(nP, nS);
avgRiRate = zeros(nP, nS);
avgRjRate = zeros(nP, nS);
avgMaxMinRate = zeros(nP, nS);
avgJainFairness = zeros(nP, nS);
avgOptXi = zeros(nP, nS);
avgOptZeta = zeros(nP, nS);

perMcPower = cell(nP, 1);

for ip = 1:nP
    ps = power_dbm_to_watt(psDbmList(ip));

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
            opt_proposed_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alphaDefault, noiseVar, xiList, zetaList);
        [x2, z2, r2i, r2j, s2, m2, j2] = ...
            opt_benchmark_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alphaDefault, noiseVar, xiList, zetaFixed);
        [x3, z3, r3i, r3j, s3, m3, j3] = ...
            opt_pure_noma_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alphaDefault, noiseVar, xiList);

        mcSum(imc, :) = [s1 s2 s3];
        mcRi(imc, :) = [r1i r2i r3i];
        mcRj(imc, :) = [r1j r2j r3j];
        mcMin(imc, :) = [m1 m2 m3];
        mcJain(imc, :) = [j1 j2 j3];
        mcXi(imc, :) = [x1 x2 x3];
        mcZeta(imc, :) = [z1 z2 z3];
    end

    avgSumRate(ip, :) = mean(mcSum, 1);
    avgRiRate(ip, :) = mean(mcRi, 1);
    avgRjRate(ip, :) = mean(mcRj, 1);
    avgMaxMinRate(ip, :) = mean(mcMin, 1);
    avgJainFairness(ip, :) = mean(mcJain, 1);
    avgOptXi(ip, :) = mean(mcXi, 1);
    avgOptZeta(ip, :) = mean(mcZeta, 1);

    perMcPower{ip} = {mcSum, mcRi, mcRj, mcMin, mcJain, mcXi, mcZeta};

    fprintf('[Power] %d dBm finished.\n', psDbmList(ip));
end

end
