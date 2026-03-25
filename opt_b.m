function [bx, bz, bri, brj, brs, brm, bfj] = opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, zFix)
%OPT_B Benchmark: 1D grid xi with fixed zeta.

brs = -inf; bx = xVec(1); bz = zFix; bri = 0; brj = 0; brm = 0; bfj = 0;

for ix = 1:numel(xVec)
    xi = xVec(ix);
    [~, ~, ~, ri, rj, rs, rm, jf] = rates(h1, h2, h3, g1, g2, ps, xi, zFix, al, n0);
    if rs > brs
        brs = rs; bx = xi; bz = zFix; bri = ri; brj = rj; brm = rm; bfj = jf;
    end
end

end
