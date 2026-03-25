function [sinr_i_to_j, sinr_i_to_i, sinr_j_to_j, rateRi, rateRj, sumRate, maxMinRate, jain] = ...
    calc_rates(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, xi, zeta, alpha, noiseVar)
%CALC_RATES Compute SINRs and rates.

termRi = abs(hS_Ri)^2 + zeta*abs(hS_F)^2*abs(gF_Ri)^2;
termRj = abs(hS_Rj)^2 + zeta*abs(hS_F)^2*abs(gF_Rj)^2;

sinr_i_to_j = ps*(1-xi)*termRi / (ps*xi*termRi + noiseVar);
sinr_i_to_i = ps*xi*termRi / (abs(hS_Ri)^2 * ps*(1-xi)*alpha + noiseVar);
sinr_j_to_j = ps*(1-xi)*termRj / (ps*xi*termRj + noiseVar);

rateRi = log2(1 + sinr_i_to_i);
rateRj = log2(1 + sinr_j_to_j);
sumRate = rateRi + rateRj;
maxMinRate = min(rateRi, rateRj);
jain = (sumRate^2) / (2*(rateRi^2 + rateRj^2));

end
