function [bx, bz, bri, brj, brs, brm, bfj] = opt_n(h1, h2, h3, g1, g2, ps, al, n0, xVec)
%OPT_N Pure PD-NOMA: zeta = 0.

[bx, bz, bri, brj, brs, brm, bfj] = opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, 0);

end
