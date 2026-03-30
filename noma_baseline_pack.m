function met = noma_baseline_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold)
%NOMA_BASELINE_PACK NOMA baseline family module.
% Modes:
%   pure  : Pure NOMA
%   fixed : NOMA-AmBC with fixed rho
%   opt   : NOMA-AmBC with rho grid search

switch lower(mode)
    case 'pure'
        met = local_noma_eval(ch, Pt, sic_err, sigma2, 0, rate_threshold, NaN);
    case 'fixed'
        met = local_noma_eval(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, NaN);
    case 'opt'
        met = local_noma_opt(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold);
    otherwise
        error('Unknown NOMA baseline mode: %s', mode);
end

end

function met = local_noma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho_opt)
[R1, R2] = core('rates', ch, Pt, sic_err, sigma2, rho);
total_power = Pt + 0.1 + 0.05*rho;
met = calc_pack('compute_metrics_scheme', R1, R2, total_power, rho, rho_opt, rate_threshold);
end

function met = local_noma_opt(ch, Pt, sic_err, sigma2, rho_grid, rate_threshold)
best_min = -inf;
best_sum = -inf;
best_rho = rho_grid(1);
best_met = [];

for ir = 1:numel(rho_grid)
    rho = rho_grid(ir);
    tmp = local_noma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho);
    if (tmp.max_min_rate > best_min + 1e-12) || ...
       (abs(tmp.max_min_rate - best_min) <= 1e-12 && tmp.sum_rate > best_sum)
        best_min = tmp.max_min_rate;
        best_sum = tmp.sum_rate;
        best_rho = rho;
        best_met = tmp;
    end
end

best_met.rho_opt = best_rho;
met = best_met;
end
