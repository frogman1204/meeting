%MAIN Baseline reproduction entry (single-file version).

clear; clc;

[nMC, pDef, pVec, aVec, n0, zFix, xVec, zVec, sd, sch, oDir, fP, fA, cP, cA, aDef] = local_params();
rng(sd);

fprintf('=== Reproduction Start ===\n');
fprintf('nMC=%d, n0=%.3f, zFix=%.2f\n', nMC, n0, zFix);

[aSp, aIp, aJp, aMp, aFp, aXp, aZp, mcP] = local_swp_p(nMC, pVec, sch, aDef, n0, xVec, zVec, zFix);
[aSa, aIa, aJa, aMa, aFa, aXa, aZa, mcA] = local_swp_a(nMC, pDef, aVec, sch, n0, xVec, zVec, zFix);

tp = local_tbl(pVec, 'Ps_dBm', aSp, aIp, aJp, aMp, aFp, aXp, aZp, sch);
ta = local_tbl(aVec, 'alpha', aSa, aIa, aJa, aMa, aFa, aXa, aZa, sch);

fp = local_plt_p(pVec, aSp, sch);
fa = local_plt_a(aVec, aSa, sch);

raw = {nMC,pDef,pVec,aVec,n0,zFix,xVec,zVec,aDef,aSp,aIp,aJp,aMp,aFp,aXp,aZp,mcP,aSa,aIa,aJa,aMa,aFa,aXa,aZa,mcA};
local_save_o(oDir, fP, fA, cP, cA, fp, fa, tp, ta, 'all_results.mat', raw);

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

function [nMC, pDef, pVec, aVec, n0, zFix, xVec, zVec, sd, sch, oDir, fP, fA, cP, cA, aDef] = local_params()
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

function [aS, aI, aJ, aM, aF, aX, aZ, mcP] = local_swp_p(nMC, pVec, sch, aDef, n0, xVec, zVec, zFix)
    nP = numel(pVec); nS = numel(sch);
    aS = zeros(nP, nS); aI = zeros(nP, nS); aJ = zeros(nP, nS);
    aM = zeros(nP, nS); aF = zeros(nP, nS); aX = zeros(nP, nS); aZ = zeros(nP, nS);
    mcP = cell(nP, 1);

    for ip = 1:nP
        ps = local_p2w(pVec(ip));
        mS = zeros(nMC, nS); mI = zeros(nMC, nS); mJ = zeros(nMC, nS);
        mM = zeros(nMC, nS); mF = zeros(nMC, nS); mX = zeros(nMC, nS); mZ = zeros(nMC, nS);

        for im = 1:nMC
            [h1, h2, h3, g1, g2] = local_ch();
            [x1, z1, i1, j1, s1, m1, f1] = local_opt_p(h1, h2, h3, g1, g2, ps, aDef, n0, xVec, zVec);
            [x2, z2, i2, j2, s2, m2, f2] = local_opt_b(h1, h2, h3, g1, g2, ps, aDef, n0, xVec, zFix);
            [x3, z3, i3, j3, s3, m3, f3] = local_opt_n(h1, h2, h3, g1, g2, ps, aDef, n0, xVec);

            mS(im, :) = [s1 s2 s3]; mI(im, :) = [i1 i2 i3]; mJ(im, :) = [j1 j2 j3];
            mM(im, :) = [m1 m2 m3]; mF(im, :) = [f1 f2 f3]; mX(im, :) = [x1 x2 x3]; mZ(im, :) = [z1 z2 z3];
        end

        aS(ip, :) = mean(mS, 1); aI(ip, :) = mean(mI, 1); aJ(ip, :) = mean(mJ, 1);
        aM(ip, :) = mean(mM, 1); aF(ip, :) = mean(mF, 1); aX(ip, :) = mean(mX, 1); aZ(ip, :) = mean(mZ, 1);
        mcP{ip} = {mS, mI, mJ, mM, mF, mX, mZ};
        fprintf('[Power] %d dBm finished.\n', pVec(ip));
    end
end

function [aS, aI, aJ, aM, aF, aX, aZ, mcA] = local_swp_a(nMC, pDef, aVec, sch, n0, xVec, zVec, zFix)
    nA = numel(aVec); nS = numel(sch); ps = local_p2w(pDef);
    aS = zeros(nA, nS); aI = zeros(nA, nS); aJ = zeros(nA, nS);
    aM = zeros(nA, nS); aF = zeros(nA, nS); aX = zeros(nA, nS); aZ = zeros(nA, nS);
    mcA = cell(nA, 1);

    for ia = 1:nA
        al = aVec(ia);
        mS = zeros(nMC, nS); mI = zeros(nMC, nS); mJ = zeros(nMC, nS);
        mM = zeros(nMC, nS); mF = zeros(nMC, nS); mX = zeros(nMC, nS); mZ = zeros(nMC, nS);

        for im = 1:nMC
            [h1, h2, h3, g1, g2] = local_ch();
            [x1, z1, i1, j1, s1, m1, f1] = local_opt_p(h1, h2, h3, g1, g2, ps, al, n0, xVec, zVec);
            [x2, z2, i2, j2, s2, m2, f2] = local_opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, zFix);
            [x3, z3, i3, j3, s3, m3, f3] = local_opt_n(h1, h2, h3, g1, g2, ps, al, n0, xVec);

            mS(im, :) = [s1 s2 s3]; mI(im, :) = [i1 i2 i3]; mJ(im, :) = [j1 j2 j3];
            mM(im, :) = [m1 m2 m3]; mF(im, :) = [f1 f2 f3]; mX(im, :) = [x1 x2 x3]; mZ(im, :) = [z1 z2 z3];
        end

        aS(ia, :) = mean(mS, 1); aI(ia, :) = mean(mI, 1); aJ(ia, :) = mean(mJ, 1);
        aM(ia, :) = mean(mM, 1); aF(ia, :) = mean(mF, 1); aX(ia, :) = mean(mX, 1); aZ(ia, :) = mean(mZ, 1);
        mcA{ia} = {mS, mI, mJ, mM, mF, mX, mZ};
        fprintf('[Alpha] %.1f finished.\n', al);
    end
end

function [bx, bz, bri, brj, brs, brm, bfj] = local_opt_p(h1, h2, h3, g1, g2, ps, al, n0, xVec, zVec)
    brs = -inf; bx = xVec(1); bz = zVec(1); bri = 0; brj = 0; brm = 0; bfj = 0;
    for ix = 1:numel(xVec)
        for iz = 1:numel(zVec)
            xi = xVec(ix); ze = zVec(iz);
            [~, ~, ~, ri, rj, rs, rm, jf] = local_rates(h1, h2, h3, g1, g2, ps, xi, ze, al, n0);
            if rs > brs
                brs = rs; bx = xi; bz = ze; bri = ri; brj = rj; brm = rm; bfj = jf;
            end
        end
    end
end

function [bx, bz, bri, brj, brs, brm, bfj] = local_opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, zFix)
    brs = -inf; bx = xVec(1); bz = zFix; bri = 0; brj = 0; brm = 0; bfj = 0;
    for ix = 1:numel(xVec)
        xi = xVec(ix);
        [~, ~, ~, ri, rj, rs, rm, jf] = local_rates(h1, h2, h3, g1, g2, ps, xi, zFix, al, n0);
        if rs > brs
            brs = rs; bx = xi; bz = zFix; bri = ri; brj = rj; brm = rm; bfj = jf;
        end
    end
end

function [bx, bz, bri, brj, brs, brm, bfj] = local_opt_n(h1, h2, h3, g1, g2, ps, al, n0, xVec)
    [bx, bz, bri, brj, brs, brm, bfj] = local_opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, 0);
end

function [sij, sii, sjj, ri, rj, rs, rmin, jf] = local_rates(h1, h2, h3, g1, g2, ps, xi, ze, al, n0)
    t1 = abs(h1)^2 + ze*abs(h3)^2*abs(g1)^2;
    t2 = abs(h2)^2 + ze*abs(h3)^2*abs(g2)^2;

    sij = ps*(1-xi)*t1 / (ps*xi*t1 + n0);
    sii = ps*xi*t1 / (abs(h1)^2 * ps*(1-xi)*al + n0);
    sjj = ps*(1-xi)*t2 / (ps*xi*t2 + n0);

    ri = log2(1 + sii);
    rj = log2(1 + sjj);
    rs = ri + rj;
    rmin = min(ri, rj);
    jf = (rs^2) / (2*(ri^2 + rj^2));
end

function [h1, h2, h3, g1, g2] = local_ch()
    h1 = (randn + 1i*randn)/sqrt(2);
    h2 = (randn + 1i*randn)/sqrt(2);
    h3 = (randn + 1i*randn)/sqrt(2);
    g1 = (randn + 1i*randn)/sqrt(2);
    g2 = (randn + 1i*randn)/sqrt(2);
end

function pw = local_p2w(pd)
    pw = 10.^((pd - 30)./10);
end

function T = local_tbl(x, t, aS, aI, aJ, aM, aF, aX, aZ, sch)
    nX = numel(x); nS = numel(sch); nR = nX*nS;
    pCol = nan(nR,1); aCol = nan(nR,1); sCol = strings(nR,1);
    S = zeros(nR,1); I = zeros(nR,1); J = zeros(nR,1); M = zeros(nR,1); F = zeros(nR,1); X = zeros(nR,1); Z = zeros(nR,1);

    k = 1;
    for ix = 1:nX
        for is = 1:nS
            if strcmpi(t, 'Ps_dBm'); pCol(k) = x(ix); else; aCol(k) = x(ix); end
            sCol(k) = string(sch{is});
            S(k)=aS(ix,is); I(k)=aI(ix,is); J(k)=aJ(ix,is); M(k)=aM(ix,is); F(k)=aF(ix,is); X(k)=aX(ix,is); Z(k)=aZ(ix,is);
            k = k + 1;
        end
    end

    T = table(pCol, aCol, sCol, S, I, J, M, F, X, Z, 'VariableNames', ...
        {'Ps_dBm','alpha','scheme_name','avg_sum_rate','avg_Ri_rate','avg_Rj_rate','avg_max_min_rate','avg_jain_fairness','avg_opt_xi','avg_opt_zeta'});
end

function f = local_plt_p(pVec, aS, sch)
    f = figure('Color','w');
    plot(pVec, aS(:,1), '-o', 'LineWidth',1.5); hold on;
    plot(pVec, aS(:,2), '-s', 'LineWidth',1.5);
    plot(pVec, aS(:,3), '-^', 'LineWidth',1.5);
    grid on; xlabel('Source available power P_s (dBm)'); ylabel('Average sum-rate (bit/s/Hz)');
    title('Sum-rate vs Source Power'); legend(sch, 'Location','best');
end

function f = local_plt_a(aVec, aS, sch)
    f = figure('Color','w');
    plot(aVec, aS(:,1), '-o', 'LineWidth',1.5); hold on;
    plot(aVec, aS(:,2), '-s', 'LineWidth',1.5);
    plot(aVec, aS(:,3), '-^', 'LineWidth',1.5);
    grid on; xlabel('Imperfect SIC parameter \alpha'); ylabel('Average sum-rate (bit/s/Hz)');
    title('Sum-rate vs Imperfect SIC Parameter'); legend(sch, 'Location','best');
end

function local_save_o(oDir, fP, fA, cP, cA, fp, fa, tp, ta, dName, raw)
    if ~exist(oDir, 'dir'); mkdir(oDir); end
    saveas(fp, fullfile(oDir, [fP '.png']));
    savefig(fp, fullfile(oDir, [fP '.fig']));
    saveas(fa, fullfile(oDir, [fA '.png']));
    savefig(fa, fullfile(oDir, [fA '.fig']));
    writetable(tp, fullfile(oDir, cP));
    writetable(ta, fullfile(oDir, cA));
    save(fullfile(oDir, dName), 'raw');
end

function o = oma(~, ~, ~, ~)
% OMA baseline stub for future use.
    o = [NaN NaN NaN NaN NaN NaN NaN];
end
