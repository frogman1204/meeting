%MAIN Baseline reproduction entry.

clear; clc;

[nMC, pDef, pVec, aVec, n0, zFix, xVec, zVec, sd, sch, oDir, fP, fA, cP, cA, aDef] = params();
rng(sd);

fprintf('=== Reproduction Start ===\n');
fprintf('nMC=%d, n0=%.3f, zFix=%.2f\n', nMC, n0, zFix);

[aSp, aIp, aJp, aMp, aFp, aXp, aZp, mcP] = swp_p(nMC, pVec, sch, aDef, n0, xVec, zVec, zFix);
[aSa, aIa, aJa, aMa, aFa, aXa, aZa, mcA] = swp_a(nMC, pDef, aVec, sch, n0, xVec, zVec, zFix);

tp = tbl(pVec, 'Ps_dBm', aSp, aIp, aJp, aMp, aFp, aXp, aZp, sch);
ta = tbl(aVec, 'alpha', aSa, aIa, aJa, aMa, aFa, aXa, aZa, sch);

fp = plt_p(pVec, aSp, sch);
fa = plt_a(aVec, aSa, sch);

raw = {nMC,pDef,pVec,aVec,n0,zFix,xVec,zVec,aDef,aSp,aIp,aJp,aMp,aFp,aXp,aZp,mcP,aSa,aIa,aJa,aMa,aFa,aXa,aZa,mcA};
save_o(oDir, fP, fA, cP, cA, fp, fa, tp, ta, 'all_results.mat', raw);

fprintf('\n=== Checks ===\n');
for is = 1:numel(sch)
    inc = all(diff(aSp(:, is)) >= -1e-9);
    fprintf('Power trend (%s): %d\n', sch{is}, inc);
end
for is = 1:numel(sch)
    dec = all(diff(aSa(:, is)) <= 1e-9);
    fprintf('Alpha trend (%s): %d\n', sch{is}, dec);
end

k40 = find(pVec == 40, 1);
if ~isempty(k40)
    s40 = aSp(k40, :);
    ok = (s40(1) > s40(2)) && (s40(2) > s40(3));
    fprintf('At 40 dBm, proposed > benchmark > pure: %d\n', ok);
    fprintf('40 dBm sum-rate: %.4f / %.4f / %.4f\n', s40(1), s40(2), s40(3));
end

fprintf('Saved to: %s\n', oDir);
fprintf('=== Reproduction End ===\n');

% NEXT STEP
% 1) paper-style KKT + sub-gradient implementation
% 2) OMA baseline
% 3) convergence figure
% 4) energy efficiency metric
% 5) RSMA extension
