function met = noma_baseline_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, varargin)
%NOMA_BASELINE_PACK NOMA baseline family module.
% Modes:
%   pure  : Pure NOMA
%   fixed : NOMA-AmBC with fixed rho
%   opt   : NOMA-AmBC with rho grid search

if nargin >= 8
    harvest_cfg = varargin{1};
else
    harvest_cfg = struct();
end

switch lower(mode)
    case 'pure'
        met = local_noma_eval(ch, Pt, sic_err, sigma2, 0, rate_threshold, NaN);
    case 'fixed'
        met = local_noma_eval(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, NaN);
    case 'opt'
        met = local_noma_opt(ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg);
    otherwise
        error('Unknown NOMA baseline mode: %s', mode);
end

end

function met = local_noma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho_opt)
[R1, R2] = core('rates', ch, Pt, sic_err, sigma2, rho);
total_power = Pt + 0.1 + 0.05*rho;
met = calc_pack('compute_metrics_scheme', R1, R2, total_power, rho, rho_opt, rate_threshold);
end

function met = local_noma_opt(ch, Pt, sic_err, sigma2, rho_grid, rate_threshold, harvest_cfg)
persistent noma_opt_call_count;
if isempty(noma_opt_call_count), noma_opt_call_count = 0; end
noma_opt_call_count = noma_opt_call_count + 1;
do_log = (noma_opt_call_count <= 3) || (mod(noma_opt_call_count, 200) == 0);

best_min = -inf;
best_sum = -inf;
best_rho = rho_grid(1);
best_met = [];
tick = max(1, floor(numel(rho_grid)/5));
rho_max_feasible = local_rho_max_from_harvest(ch, Pt, harvest_cfg);
num_before = numel(rho_grid);
if isfinite(rho_max_feasible)
    rho_grid = rho_grid(rho_grid <= rho_max_feasible + 1e-12);
end
if isempty(rho_grid)
    rho_grid = min(max(rho_max_feasible, 0), 1);
end
num_after = numel(rho_grid);
num_skipped = max(0, num_before - num_after);

if do_log
    fprintf('[noma_opt] call=%d | rho candidates=%d | feasible rho_max=%.3f | skipped infeasible=%d\n', ...
        noma_opt_call_count, num_after, rho_max_feasible, num_skipped);
end

for ir = 1:numel(rho_grid)
    rho = rho_grid(ir);
    tmp = local_noma_eval(ch, Pt, sic_err, sigma2, rho, rate_threshold, rho);
    if do_log && (ir == 1 || ir == numel(rho_grid) || mod(ir, tick) == 0)
        fprintf('  [noma_opt] rho idx %d/%d (rho=%.3f)\n', ir, numel(rho_grid), rho);
    end
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
if do_log
    fprintf('[noma_opt] best rho=%.3f | max-min=%.4f | sum-rate=%.4f\n', ...
        best_rho, met.max_min_rate, met.sum_rate);
end

function rho_max = local_rho_max_from_harvest(ch, Pt, h)
% E_h = eta_h * (1-rho) * Pt * |hSF|^2 * T >= E_req + P_cir*T
rho_max = 1.0;
if ~isfield(h, 'enable') || ~h.enable
    return;
end
eta_h = local_get_or(h, 'eta_h', 0.6);
T = local_get_or(h, 'T', 1.0);
E_req = local_get_or(h, 'E_req', 0.0);
P_cir = local_get_or(h, 'P_cir', 0.0);
den = eta_h * Pt * abs(ch.hSF)^2 * T;
need = E_req + P_cir*T;
if den <= 0
    rho_max = 0;
else
    rho_max = 1 - need/den;
end
rho_max = min(max(rho_max, 0), 1);
end

function v = local_get_or(s, k, d)
if isfield(s, k), v = s.(k); else, v = d; end
end
end
