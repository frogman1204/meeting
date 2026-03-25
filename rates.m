function [sij, sii, sjj, ri, rj, rs, rmin, jf] = rates(h1, h2, h3, g1, g2, ps, xi, ze, al, n0)
%RATES SINR/rates/metrics.

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
