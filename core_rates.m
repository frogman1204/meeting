function [R1, R2] = core_rates(ch, Pt, sic_err, sigma2, rho)
%CORE_RATES 2-user NOMA baseline rate calculation.

xi = 0.3;
g1 = abs(ch.hSR1)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR2)^2;

sinr1 = Pt*xi*g1/(Pt*(1-xi)*g1*sic_err + sigma2);
sinr2 = Pt*(1-xi)*g2/(Pt*xi*g2 + sigma2);

R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);

end
