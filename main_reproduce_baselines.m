%MAIN_REPRODUCE_BASELINES Baseline reproduction entry script.

clear; clc;

cfg = default_params();
cfg.alphaDefault = 0.5;

rng(cfg.seed);

fprintf('=== Reproduction Start ===\n');
fprintf('numMC=%d, noiseVar=%.3f, zetaFixed=%.2f\n', cfg.numMC, cfg.noiseVar, cfg.zetaFixed);

resPower = sweep_power(cfg);
resAlpha = sweep_alpha(cfg);

tablePower = make_results_table(cfg.psDbmList, 'Ps_dBm', resPower, cfg.schemeList);
tableAlpha = make_results_table(cfg.alphaList, 'alpha', resAlpha, cfg.schemeList);

figPower = plot_sumrate_vs_power(cfg.psDbmList, resPower.avgSumRate, cfg.schemeList);
figAlpha = plot_sumrate_vs_alpha(cfg.alphaList, resAlpha.avgSumRate, cfg.schemeList);

save_results(cfg, figPower, figAlpha, tablePower, tableAlpha, resPower, resAlpha);

fprintf('\n=== Checks ===\n');
for is = 1:numel(cfg.schemeList)
    increasing = all(diff(resPower.avgSumRate(:, is)) >= -1e-9);
    fprintf('Power trend (%s): %d\n', cfg.schemeList{is}, increasing);
end
for is = 1:numel(cfg.schemeList)
    decreasing = all(diff(resAlpha.avgSumRate(:, is)) <= 1e-9);
    fprintf('Alpha trend (%s): %d\n', cfg.schemeList{is}, decreasing);
end

idx40 = find(cfg.psDbmList == 40, 1);
if ~isempty(idx40)
    sum40 = resPower.avgSumRate(idx40, :);
    orderOK = (sum40(1) > sum40(2)) && (sum40(2) > sum40(3));
    fprintf('At 40 dBm, proposed > benchmark > pure: %d\n', orderOK);
    fprintf('40 dBm sum-rate: %.4f / %.4f / %.4f\n', sum40(1), sum40(2), sum40(3));
end

fprintf('Saved to: %s\n', cfg.outDir);
fprintf('=== Reproduction End ===\n');

% NEXT STEP
% 1) paper-style KKT + sub-gradient implementation
% 2) OMA baseline
% 3) convergence figure
% 4) energy efficiency metric
% 5) RSMA extension
