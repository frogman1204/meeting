function met = solve_noma_ambc_fixed(ch, Pt, sic_err, sigma2, rho_fixed, rate_threshold)
%SOLVE_NOMA_AMBC_FIXED NOMA-AmBC with fixed rho.

met = local_eval_noma(ch, Pt, sic_err, sigma2, rho_fixed, rate_threshold, NaN);

end

function met = local_eval_noma(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho_opt)
xi = 0.3;
g1 = abs(ch.hSR1)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR2)^2;

sinr1 = Pt*xi*g1/(Pt*(1-xi)*g1*sic_err + sigma2);
sinr2 = Pt*(1-xi)*g2/(Pt*xi*g2 + sigma2);

R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);

total_power = Pt + 0.1 + 0.05*rho;
met = compute_metrics_scheme(R1, R2, total_power, rho, rho_opt, rate_threshold);
end
