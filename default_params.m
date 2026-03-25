function [numMC, psDbmDefault, psDbmList, alphaList, noiseVar, zetaFixed, xiList, zetaList, seed, ...
    schemeList, outDir, figPowerName, figAlphaName, csvPowerName, csvAlphaName, alphaDefault] = default_params()
%DEFAULT_PARAMS Return default simulation settings as plain outputs.

numMC = 1000;
psDbmDefault = 40;
psDbmList = 10:3:40;
alphaList = 0.1:0.1:0.9;
noiseVar = 0.1;
zetaFixed = 0.5;
xiList = 0:0.005:0.5;
zetaList = 0:0.01:1;
seed = 20260325;
alphaDefault = 0.5;

schemeList = {'proposed', 'benchmark', 'pure'};

outDir = 'out';
figPowerName = 'fig_sumrate_power';
figAlphaName = 'fig_sumrate_alpha';
csvPowerName = 'res_power.csv';
csvAlphaName = 'res_alpha.csv';

% NEXT STEP
% 1) paper-style KKT + sub-gradient implementation
% 2) OMA baseline
% 3) convergence figure
% 4) energy efficiency metric
% 5) RSMA extension

end
