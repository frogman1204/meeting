function met = noma_baseline_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, varargin)
%NOMA_BASELINE_PACK NOMA/OMA baseline module.

if nargin >= 8, harvest_cfg = varargin{1}; else, harvest_cfg = struct(); end
if nargin >= 9, xi_grid = varargin{2}; else, xi_grid = 0.05:0.05:0.95; end
if nargin >= 10, experiment_mode = varargin{3}; else, experiment_mode = 'research_rsma'; end
if nargin >= 11, ambc_cfg = varargin{4}; else, ambc_cfg = struct(); end

switch lower(mode)
    case 'pure'
        met = local_noma_optimize(ch, Pt, sic_err, sigma2, 0, xi_grid, rate_threshold, harvest_cfg, false, experiment_mode, false, ambc_cfg);
    case 'fixed'
        met = local_noma_optimize(ch, Pt, sic_err, sigma2, rho_arg, xi_grid, rate_threshold, harvest_cfg, false, experiment_mode, true, ambc_cfg);
    case 'opt'
        met = local_noma_optimize(ch, Pt, sic_err, sigma2, rho_arg, xi_grid, rate_threshold, harvest_cfg, true, experiment_mode, true, ambc_cfg);
    case 'oma_pure'
        met = local_oma_eval(ch, Pt, sigma2, 0, rate_threshold);
    case 'oma'
        met = local_oma_eval(ch, Pt, sigma2, rho_arg(1), rate_threshold);
    otherwise
        error('Unknown NOMA baseline mode: %s', mode);
end

end

function met = local_noma_eval(ch, Pt, sic_err, sigma2, rho, xi, rate_threshold, rho_opt, use_paper_rates, ambc_cfg)
if use_paper_rates
    [R1, R2] = core('rates_paper_noma', ch, Pt, sic_err, sigma2, rho, xi);
else
    [R1, R2, out] = core('rates', ch, Pt, sic_err, sigma2, rho, xi, ambc_cfg);
end
total_power = Pt + 0.1 + 0.05*rho;
met = calc_pack('compute_metrics_scheme', R1, R2, total_power, rho, rho_opt, rate_threshold);
met.xi_used = xi;
if exist('out','var') && isfield(out,'tag_ber'), met.ber_tag = out.tag_ber; end
end

function met = local_oma_eval(ch, Pt, sigma2, rho, rate_threshold)
[R1, R2] = core('rates_paper_oma', ch, Pt, sigma2, rho);
total_power = Pt + 0.1 + 0.05*rho;
met = calc_pack('compute_metrics_scheme', R1, R2, total_power, rho, rho, rate_threshold);
met.xi_used = NaN;
end

function met = local_noma_optimize(ch, Pt, sic_err, sigma2, rho_arg, xi_grid, rate_threshold, harvest_cfg, allow_rho_opt, experiment_mode, use_paper_rates, ambc_cfg)
best_primary = -inf;
best_secondary = -inf;
if allow_rho_opt, rho_grid = rho_arg; else, rho_grid = rho_arg(1); end
best_rho = rho_grid(1); best_xi = xi_grid(1); best_met = [];

rho_max_feasible = local_rho_max_from_harvest(ch, Pt, harvest_cfg);
num_before = numel(rho_grid);
if isfinite(rho_max_feasible), rho_grid = rho_grid(rho_grid <= rho_max_feasible + 1e-12); end
if isempty(rho_grid), rho_grid = min(max(rho_max_feasible, 0), 1); end
num_after = numel(rho_grid); num_skipped = max(0, num_before - num_after);

for ir = 1:numel(rho_grid)
    rho = rho_grid(ir);
    for ix = 1:numel(xi_grid)
        xi = xi_grid(ix);
        tmp = local_noma_eval(ch, Pt, sic_err, sigma2, rho, xi, rate_threshold, rho, use_paper_rates, ambc_cfg);
        if strcmpi(experiment_mode, 'paper_reproduction')
            primary = tmp.sum_rate;
            secondary = tmp.max_min_rate;
        else
            primary = tmp.max_min_rate;
            secondary = tmp.sum_rate;
        end
        if (primary > best_primary + 1e-12) || (abs(primary - best_primary) <= 1e-12 && secondary > best_secondary)
            best_primary = primary; best_secondary = secondary;
            best_rho = rho; best_xi = xi; best_met = tmp;
        end
    end
end

best_met.rho_opt = best_rho;
best_met.xi_opt = best_xi;
best_met.rho_feasible_max = rho_max_feasible;
best_met.hit_feasible_bound = abs(best_rho - rho_max_feasible) <= 1e-9;
best_met.infeasible_skip_frac = num_skipped / max(num_before, 1);
met = best_met;
if strcmpi(experiment_mode, 'paper_reproduction') && local_get_or(harvest_cfg, 'debug_paper_noma', false)
    fprintf('[paper_noma] obj=sum-rate-first | rho=%.3f | xi=%.3f | sum=%.4f | mm=%.4f\n', ...
        met.rho_opt, met.xi_opt, met.sum_rate, met.max_min_rate);
end
end

function rho_max = local_rho_max_from_harvest(ch, Pt, h)
rho_max = 1.0;
if ~isfield(h, 'enable') || ~h.enable, return; end
eta_h = local_get_or(h, 'eta_h', 0.6);
T = local_get_or(h, 'T', 1.0);
E_req = local_get_or(h, 'E_req', 0.0);
P_cir = local_get_or(h, 'P_cir', 0.0);
den = eta_h * Pt * abs(ch.hSF)^2 * T;
need = E_req + P_cir*T;
if den <= 0, rho_max = 0; else, rho_max = 1 - need/den; end
rho_max = min(max(rho_max, 0), 1);
end

function v = local_get_or(s, k, d)
if isfield(s, k), v = s.(k); else, v = d; end
end
