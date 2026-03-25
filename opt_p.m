function [bx, bz, bri, brj, brs, brm, bfj] = opt_p(h1, h2, h3, g1, g2, ps, al, n0, xVec, zVec)
%OPT_P Proposed: 2D grid over xi and zeta.

brs = -inf; bx = xVec(1); bz = zVec(1); bri = 0; brj = 0; brm = 0; bfj = 0;

for ix = 1:numel(xVec)
    for iz = 1:numel(zVec)
        xi = xVec(ix); ze = zVec(iz);
        [~, ~, ~, ri, rj, rs, rm, jf] = rates(h1, h2, h3, g1, g2, ps, xi, ze, al, n0);
        if rs > brs
            brs = rs; bx = xi; bz = ze; bri = ri; brj = rj; brm = rm; bfj = jf;
        end
    end
end

end
