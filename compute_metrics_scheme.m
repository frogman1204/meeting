function met = compute_metrics_scheme(R1, R2, total_power, rho_used, rho_opt, rate_threshold)
%COMPUTE_METRICS_SCHEME Build metric struct from rates.

met.R1 = R1;
met.R2 = R2;
met.sum_rate = R1 + R2;
met.max_min_rate = min(R1, R2);
met.jain_fairness = calc_jain(R1, R2);
met.energy_efficiency = calc_ee(met.sum_rate, total_power);
met.rho_used = rho_used;
met.rho_opt = rho_opt;
met.ber_tag = NaN;      % TODO: BER implementation
met.ber_user1 = NaN;    % TODO: BER implementation
met.ber_user2 = NaN;    % TODO: BER implementation
met.outage_flag = (met.max_min_rate < rate_threshold);

end
