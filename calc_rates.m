function met = calc_rates(chan, ps, xi, zeta, alpha, noiseVar)
%CALC_RATES Compute SINRs and rates.

termRi = abs(chan.hS_Ri)^2 + zeta*abs(chan.hS_F)^2*abs(chan.gF_Ri)^2;
termRj = abs(chan.hS_Rj)^2 + zeta*abs(chan.hS_F)^2*abs(chan.gF_Rj)^2;

met.sinr_i_to_j = ps*(1-xi)*termRi / (ps*xi*termRi + noiseVar);
met.sinr_i_to_i = ps*xi*termRi / (abs(chan.hS_Ri)^2 * ps*(1-xi)*alpha + noiseVar);
met.sinr_j_to_j = ps*(1-xi)*termRj / (ps*xi*termRj + noiseVar);

met.rateRi = log2(1 + met.sinr_i_to_i);
met.rateRj = log2(1 + met.sinr_j_to_j);
met.sumRate = met.rateRi + met.rateRj;
met.maxMinRate = min(met.rateRi, met.rateRj);
met.jain = (met.sumRate^2) / (2*(met.rateRi^2 + met.rateRj^2));

end
