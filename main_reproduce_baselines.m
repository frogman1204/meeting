%MAIN_REPRODUCE_BASELINES Baseline reproduction entry script.

clear; clc;

[numMC, psDbmDefault, psDbmList, alphaList, noiseVar, zetaFixed, xiList, zetaList, seed, ...
    schemeList, outDir, figPowerName, figAlphaName, csvPowerName, csvAlphaName, alphaDefault] = default_params();

rng(seed);

fprintf('=== Reproduction Start ===\n');
fprintf('numMC=%d, noiseVar=%.3f, zetaFixed=%.2f\n', numMC, noiseVar, zetaFixed);

[avgSumPower, avgRiPower, avgRjPower, avgMinPower, avgJainPower, avgXiPower, avgZetaPower, perMcPower] = ...
    sweep_power(numMC, psDbmList, schemeList, alphaDefault, noiseVar, xiList, zetaList, zetaFixed);

[avgSumAlpha, avgRiAlpha, avgRjAlpha, avgMinAlpha, avgJainAlpha, avgXiAlpha, avgZetaAlpha, perMcAlpha] = ...
    sweep_alpha(numMC, psDbmDefault, alphaList, schemeList, noiseVar, xiList, zetaList, zetaFixed);

tablePower = make_results_table(psDbmList, 'Ps_dBm', avgSumPower, avgRiPower, avgRjPower, avgMinPower, avgJainPower, avgXiPower, avgZetaPower, schemeList);
tableAlpha = make_results_table(alphaList, 'alpha', avgSumAlpha, avgRiAlpha, avgRjAlpha, avgMinAlpha, avgJainAlpha, avgXiAlpha, avgZetaAlpha, schemeList);

figPower = plot_sumrate_vs_power(psDbmList, avgSumPower, schemeList);
figAlpha = plot_sumrate_vs_alpha(alphaList, avgSumAlpha, schemeList);

rawData = {numMC, psDbmDefault, psDbmList, alphaList, noiseVar, zetaFixed, xiList, zetaList, alphaDefault, ...
    avgSumPower, avgRiPower, avgRjPower, avgMinPower, avgJainPower, avgXiPower, avgZetaPower, perMcPower, ...
    avgSumAlpha, avgRiAlpha, avgRjAlpha, avgMinAlpha, avgJainAlpha, avgXiAlpha, avgZetaAlpha, perMcAlpha};

save_results(outDir, figPowerName, figAlphaName, csvPowerName, csvAlphaName, ...
    figPower, figAlpha, tablePower, tableAlpha, 'all_results.mat', rawData);

fprintf('\n=== Checks ===\n');
for is = 1:numel(schemeList)
    increasing = all(diff(avgSumPower(:, is)) >= -1e-9);
    fprintf('Power trend (%s): %d\n', schemeList{is}, increasing);
end
for is = 1:numel(schemeList)
    decreasing = all(diff(avgSumAlpha(:, is)) <= 1e-9);
    fprintf('Alpha trend (%s): %d\n', schemeList{is}, decreasing);
end

idx40 = find(psDbmList == 40, 1);
if ~isempty(idx40)
    sum40 = avgSumPower(idx40, :);
    orderOK = (sum40(1) > sum40(2)) && (sum40(2) > sum40(3));
    fprintf('At 40 dBm, proposed > benchmark > pure: %d\n', orderOK);
    fprintf('40 dBm sum-rate: %.4f / %.4f / %.4f\n', sum40(1), sum40(2), sum40(3));
end

fprintf('Saved to: %s\n', outDir);
fprintf('=== Reproduction End ===\n');

% NEXT STEP
% 1) paper-style KKT + sub-gradient implementation
% 2) OMA baseline
% 3) convergence figure
% 4) energy efficiency metric
% 5) RSMA extension
