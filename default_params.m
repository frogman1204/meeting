function cfg = default_params()
%DEFAULT_PARAMS Return default simulation settings.

cfg.numMC = 1000;
cfg.psDbmDefault = 40;
cfg.psDbmList = 10:3:40;
cfg.alphaList = 0.1:0.1:0.9;
cfg.noiseVar = 0.1;
cfg.zetaFixed = 0.5;
cfg.xiList = 0:0.005:0.5;
cfg.zetaList = 0:0.01:1;
cfg.seed = 20260325;

cfg.schemeList = {'proposed', 'benchmark', 'pure'};

cfg.outDir = 'out';
cfg.figPowerName = 'fig_sumrate_power';
cfg.figAlphaName = 'fig_sumrate_alpha';
cfg.csvPowerName = 'res_power.csv';
cfg.csvAlphaName = 'res_alpha.csv';

% NEXT STEP
% 1) paper-style KKT + sub-gradient implementation
% 2) OMA baseline
% 3) convergence figure
% 4) energy efficiency metric
% 5) RSMA extension

end
