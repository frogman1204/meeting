function [aS, aI, aJ, aM, aF, aX, aZ, mcA] = swp_a(nMC, pDef, aVec, sch, n0, xVec, zVec, zFix)
%SWP_A Sweep imperfect SIC alpha.

nA = numel(aVec); nS = numel(sch); ps = p2w(pDef);
aS = zeros(nA, nS); aI = zeros(nA, nS); aJ = zeros(nA, nS);
aM = zeros(nA, nS); aF = zeros(nA, nS); aX = zeros(nA, nS); aZ = zeros(nA, nS);
mcA = cell(nA, 1);

for ia = 1:nA
    al = aVec(ia);
    mS = zeros(nMC, nS); mI = zeros(nMC, nS); mJ = zeros(nMC, nS);
    mM = zeros(nMC, nS); mF = zeros(nMC, nS); mX = zeros(nMC, nS); mZ = zeros(nMC, nS);

    for im = 1:nMC
        [h1, h2, h3, g1, g2] = ch();
        [x1, z1, i1, j1, s1, m1, f1] = opt_p(h1, h2, h3, g1, g2, ps, al, n0, xVec, zVec);
        [x2, z2, i2, j2, s2, m2, f2] = opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, zFix);
        [x3, z3, i3, j3, s3, m3, f3] = opt_n(h1, h2, h3, g1, g2, ps, al, n0, xVec);

        mS(im, :) = [s1 s2 s3]; mI(im, :) = [i1 i2 i3]; mJ(im, :) = [j1 j2 j3];
        mM(im, :) = [m1 m2 m3]; mF(im, :) = [f1 f2 f3]; mX(im, :) = [x1 x2 x3]; mZ(im, :) = [z1 z2 z3];
    end

    aS(ia, :) = mean(mS, 1); aI(ia, :) = mean(mI, 1); aJ(ia, :) = mean(mJ, 1);
    aM(ia, :) = mean(mM, 1); aF(ia, :) = mean(mF, 1); aX(ia, :) = mean(mX, 1); aZ(ia, :) = mean(mZ, 1);
    mcA{ia} = {mS, mI, mJ, mM, mF, mX, mZ};
    fprintf('[Alpha] %.1f finished.\n', al);
end

end
