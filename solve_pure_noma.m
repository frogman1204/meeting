function met = solve_pure_noma(ch, Pt, sic_err, sigma2, rate_threshold)
%SOLVE_PURE_NOMA Pure NOMA without AmBC.

xi = 0.3;
rho = 0;
g1 = abs(ch.hSR1)^2;
g2 = abs(ch.hSR2)^2;

sinr1 = Pt*xi*g1/(Pt*(1-xi)*g1*sic_err + sigma2);
sinr2 = Pt*(1-xi)*g2/(Pt*xi*g2 + sigma2);

R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);

total_power = Pt + 0.1;
met = compute_metrics_scheme(R1, R2, total_power, rho, NaN, rate_threshold);

end
