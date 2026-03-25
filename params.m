function [nMC, pDef, pVec, aVec, n0, zFix, xVec, zVec, sd, sch, oDir, fP, fA, cP, cA, aDef] = params()
%PARAMS Default settings.

nMC = 1000;
pDef = 40;
pVec = 10:3:40;
aVec = 0.1:0.1:0.9;
n0 = 0.1;
zFix = 0.5;
xVec = 0:0.005:0.5;
zVec = 0:0.01:1;
sd = 20260325;
aDef = 0.5;

sch = {'proposed', 'benchmark', 'pure'};

oDir = 'out';
fP = 'fig_sumrate_power';
fA = 'fig_sumrate_alpha';
cP = 'res_power.csv';
cA = 'res_alpha.csv';

end
