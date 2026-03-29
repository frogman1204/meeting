function [R1, R2] = core_rates_rsma(ch, Pt, sic_err, sigma2, rho)
%CORE_RATES_RSMA 2-user simplified RSMA rate calculation.

pc = 0.2;
eta = 0.5;
Pc = Pt*pc;
P1 = Pt*(1-pc)*eta;
P2 = Pt*(1-pc)*(1-eta);

g1 = abs(ch.hSR1)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR2)^2;

sinr_c1 = Pc*g1/(P1*g1 + P2*g1 + sigma2);
sinr_c2 = Pc*g2/(P1*g2 + P2*g2 + sigma2);
Rc = min(log2(1 + sinr_c1), log2(1 + sinr_c2));

sinr_p1 = P1*g1/(P2*g1*sic_err + sigma2);
sinr_p2 = P2*g2/(P1*g2 + sigma2);

R1 = 0.5*Rc + log2(1 + sinr_p1);
R2 = 0.5*Rc + log2(1 + sinr_p2);

end
