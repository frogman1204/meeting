function met = rsma_proposed_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, varargin)
%RSMA_PROPOSED_PACK RSMA/proposed family module.
% Modes:
%   pure  : Pure RSMA
%   fixed : RSMA-AmBC with fixed rho
%   opt   : RSMA-AmBC with rho grid search

if nargin >= 8
    harvest_cfg = varargin{1};
else
    harvest_cfg = struct();
end

switch lower(mode)
    case 'pure'
        met = local_rsma_eval(ch, Pt, sic_err, sigma2, 0, rate_threshold, NaN);
    case 'fixed'
        met = local_rsma_eval(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, NaN);
    case 'opt'
        met = local_rsma_opt(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg);
    otherwise
        error('Unknown RSMA proposed mode: %s', mode);
end

end

function met = local_rsma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho_opt, rsma_cfg)
if nargin < 8
    rsma_cfg = [];
end
[R1, R2, rs] = core('rates_rsma', ch, Pt, sic_err, sigma2, rho, rsma_cfg);

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
met.Pc = rs.Pc;
met.P1 = rs.P1;
met.P2 = rs.P2;
met.mu = rs.mu;
end

function met = local_rsma_opt(ch, Pt, sic_err, sigma2, rho_grid, rate_threshold, harvest_cfg)
p_step = 0.1;
mu_grid = 0.1:0.1:0.9; % allow weaker user (user2) favoring split
best = opt('rsma_power_zeta', ch, Pt, sic_err, sigma2, rho_grid, p_step, mu_grid, harvest_cfg);
rsma_cfg = struct('Pc', best.Pc, 'P1', best.P1, 'P2', best.P2, 'mu', best.mu);
met = local_rsma_eval(ch, Pt, sic_err, sigma2, best.zeta, rate_threshold, best.zeta, rsma_cfg);

sumP = max(best.Pc + best.P1 + best.P2, eps);
alpha_c = best.Pc / sumP;
alpha_1 = best.P1 / sumP;
alpha_2 = best.P2 / sumP;
persistent rsma_pack_call_count;
if isempty(rsma_pack_call_count), rsma_pack_call_count = 0; end
rsma_pack_call_count = rsma_pack_call_count + 1;
if rsma_pack_call_count <= 3 || mod(rsma_pack_call_count, 100) == 0
    is_all_common = (alpha_c > 1-1e-9) && (alpha_1 < 1e-9) && (alpha_2 < 1e-9);
    fprintf(['[rsma_opt_pack] call=%d | zeta=%.3f | alpha_c=%.3f alpha_1=%.3f alpha_2=%.3f | ' ...
             'mu=%.3f | max-min=%.4f | sum-rate=%.4f | all-common=%d\n'], ...
        rsma_pack_call_count, best.zeta, alpha_c, alpha_1, alpha_2, best.mu, met.max_min_rate, met.sum_rate, is_all_common);
    fprintf(['[rsma_handoff] opt(Pc=%.4g,P1=%.4g,P2=%.4g,mu=%.3f) -> core_used(Pc=%.4g,P1=%.4g,P2=%.4g,mu=%.3f)\n'], ...
        best.Pc, best.P1, best.P2, best.mu, met.Pc, met.P1, met.P2, met.mu);
end
end
