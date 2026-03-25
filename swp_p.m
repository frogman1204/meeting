function [aS, aI, aJ, aM, aF, aX, aZ, mcP] = swp_p(nMC, pVec, sch, aDef, n0, xVec, zVec, zFix)
%SWP_P Sweep power.

nP = numel(pVec); nS = numel(sch);
aS = zeros(nP, nS); aI = zeros(nP, nS); aJ = zeros(nP, nS);
aM = zeros(nP, nS); aF = zeros(nP, nS); aX = zeros(nP, nS); aZ = zeros(nP, nS);
mcP = cell(nP, 1);

for ip = 1:nP
    ps = p2w(pVec(ip));
    mS = zeros(nMC, nS); mI = zeros(nMC, nS); mJ = zeros(nMC, nS);
    mM = zeros(nMC, nS); mF = zeros(nMC, nS); mX = zeros(nMC, nS); mZ = zeros(nMC, nS);

    for im = 1:nMC
        [h1, h2, h3, g1, g2] = ch();
        [x1, z1, i1, j1, s1, m1, f1] = opt_p(h1, h2, h3, g1, g2, ps, aDef, n0, xVec, zVec);
        [x2, z2, i2, j2, s2, m2, f2] = opt_b(h1, h2, h3, g1, g2, ps, aDef, n0, xVec, zFix);
        [x3, z3, i3, j3, s3, m3, f3] = opt_n(h1, h2, h3, g1, g2, ps, aDef, n0, xVec);

        mS(im, :) = [s1 s2 s3]; mI(im, :) = [i1 i2 i3]; mJ(im, :) = [j1 j2 j3];
        mM(im, :) = [m1 m2 m3]; mF(im, :) = [f1 f2 f3]; mX(im, :) = [x1 x2 x3]; mZ(im, :) = [z1 z2 z3];
    end

    aS(ip, :) = mean(mS, 1); aI(ip, :) = mean(mI, 1); aJ(ip, :) = mean(mJ, 1);
    aM(ip, :) = mean(mM, 1); aF(ip, :) = mean(mF, 1); aX(ip, :) = mean(mX, 1); aZ(ip, :) = mean(mZ, 1);
    mcP{ip} = {mS, mI, mJ, mM, mF, mX, mZ};
    fprintf('[Power] %d dBm finished.\n', pVec(ip));
end

end
