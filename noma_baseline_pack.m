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
persistent noma_opt_call_count;
if isempty(noma_opt_call_count), noma_opt_call_count = 0; end
noma_opt_call_count = noma_opt_call_count + 1;
do_log = (noma_opt_call_count <= 3) || (mod(noma_opt_call_count, 200) == 0);

best_min = -inf;
best_sum = -inf;
best_rho = rho_grid(1);
best_met = [];
tick = max(1, floor(numel(rho_grid)/5));

if do_log
    fprintf('[noma_opt] call=%d | rho candidates=%d\n', noma_opt_call_count, numel(rho_grid));
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
end
