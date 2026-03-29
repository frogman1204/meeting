function met = rsma_proposed_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold)
%RSMA_PROPOSED_PACK RSMA/proposed family module.
% Modes:
%   pure  : Pure RSMA
%   fixed : RSMA-AmBC with fixed rho
%   opt   : RSMA-AmBC with rho grid search

switch lower(mode)
    case 'pure'
        met = local_rsma_eval(ch, Pt, sic_err, sigma2, 0, rate_threshold, NaN);
    case 'fixed'
        met = local_rsma_eval(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, NaN);
    case 'opt'
        met = local_rsma_opt(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold);
    otherwise
        error('Unknown RSMA proposed mode: %s', mode);
end

end

function met = local_rsma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho_opt)
[R1, R2, rs] = core_rates_rsma(ch, Pt, sic_err, sigma2, rho);

total_power = Pt + 0.15 + 0.05*rho;
met = calc_pack('compute_metrics_scheme', R1, R2, total_power, rho, rho_opt, rate_threshold);
met.C1 = rs.C1;
met.C2 = rs.C2;
met.common_rate = rs.common_rate;
met.common_rate_u1 = rs.common_rate_u1;
met.common_rate_u2 = rs.common_rate_u2;
met.sinr_common_u1 = rs.sinr_common_u1;
met.sinr_common_u2 = rs.sinr_common_u2;
met.sinr_private_u1 = rs.sinr_private_u1;
met.sinr_private_u2 = rs.sinr_private_u2;
end

function met = local_rsma_opt(ch, Pt, sic_err, sigma2, rho_grid, rate_threshold)
best_sum = -inf;
best_rho = rho_grid(1);
best_met = [];

for ir = 1:numel(rho_grid)
    rho = rho_grid(ir);
    tmp = local_rsma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho);
    if tmp.sum_rate > best_sum
        best_sum = tmp.sum_rate;
        best_rho = rho;
        best_met = tmp;
    end
end

best_met.rho_opt = best_rho;
met = best_met;
end
