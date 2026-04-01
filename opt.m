function out = opt(mode, varargin)
%OPT Grouped opt_* functionality in one file.
% Modes:
%   'p'               -> NOMA rho optimizer wrapper
%   'b'               -> NOMA fixed-rho benchmark wrapper
%   'rsma_power'      -> RSMA power split optimization (fixed zeta)
%   'rsma_power_zeta' -> RSMA zeta + power split optimization

switch lower(mode)
    case 'p'
        out = noma_baseline_pack('opt', varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6});
    case 'b'
        out = noma_baseline_pack('fixed', varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6});
    case 'rsma_power'
        out = local_rsma_power(varargin{:});
    case 'rsma_power_zeta'
        out = local_rsma_power_zeta(varargin{:});
    otherwise
        error('Unknown opt mode: %s', mode);
end

end

function best = local_rsma_power(ch, Ps, sic_err, sigma2, zeta_fixed, p_step, mu_grid, harvest_cfg)
if nargin < 6
    p_step = 0.05;
end
if nargin < 7 || isempty(mu_grid)
    mu_grid = 0.1:0.1:0.9;
end
if nargin < 8
    harvest_cfg = struct();
end

alphas = 0:p_step:1;
max_common_frac = local_get_or(harvest_cfg, 'max_common_frac', 1.0);
min_private_frac = local_get_or(harvest_cfg, 'min_private_frac', 0.0);

best.max_min_rate = -inf;
best.sum_rate = -inf;
best.Pc = 0; best.P1 = 0; best.P2 = 0;
best.zeta = zeta_fixed;
best.mu = 0.5;
best.R1 = 0; best.R2 = 0; best.Rc = 0; best.C1 = 0; best.C2 = 0;
best.alpha_c = 0; best.alpha_1 = 0; best.alpha_2 = 0;
best.all_common = false;
for ac = alphas
    for a1 = alphas
        if ac + a1 > 1, continue; end
        a2 = 1 - ac - a1;
        if ac > max_common_frac + 1e-12, continue; end
        if a1 < min_private_frac - 1e-12 || a2 < min_private_frac - 1e-12, continue; end
        Pc = Ps * ac; P1 = Ps * a1; P2 = Ps * a2;
        for imu = 1:numel(mu_grid)
            mu = mu_grid(imu);
            cfg = struct('Pc', Pc, 'P1', P1, 'P2', P2, 'mu', mu);
            [R1, R2, rs] = core('rates_rsma', ch, Ps, sic_err, sigma2, zeta_fixed, cfg);
            sum_rate = R1 + R2;
            max_min_rate = min(R1, R2);

            if (max_min_rate > best.max_min_rate + 1e-12) || ...
               (abs(max_min_rate - best.max_min_rate) <= 1e-12 && sum_rate > best.sum_rate)
                best.max_min_rate = max_min_rate;
                best.sum_rate = sum_rate;
                best.Pc = rs.Pc; best.P1 = rs.P1; best.P2 = rs.P2;
                best.mu = mu;
                best.R1 = R1; best.R2 = R2; best.Rc = rs.common_rate;
                best.C1 = rs.C1; best.C2 = rs.C2;
                sumP = max(rs.Pc + rs.P1 + rs.P2, eps);
                best.alpha_c = rs.Pc / sumP;
                best.alpha_1 = rs.P1 / sumP;
                best.alpha_2 = rs.P2 / sumP;
                best.all_common = local_is_all_common(Ps, rs.Pc, rs.P1, rs.P2);
            end
        end
    end
end
end

function best = local_rsma_power_zeta(ch, Ps, sic_err, sigma2, zeta_grid, p_step, mu_grid, harvest_cfg)
if nargin < 6
    p_step = 0.05;
end
if nargin < 7 || isempty(mu_grid)
    mu_grid = 0.1:0.1:0.9;
end
if nargin < 8
    harvest_cfg = struct();
end

best.max_min_rate = -inf;
best.sum_rate = -inf;
best.Pc = 0; best.P1 = 0; best.P2 = 0;
best.zeta = 0;
best.mu = 0.5;
best.R1 = 0; best.R2 = 0; best.Rc = 0; best.C1 = 0; best.C2 = 0;
best.alpha_c = 0; best.alpha_1 = 0; best.alpha_2 = 0;
best.all_common = false;
persistent rsma_opt_call_count;
if isempty(rsma_opt_call_count), rsma_opt_call_count = 0; end
rsma_opt_call_count = rsma_opt_call_count + 1;
do_log = (rsma_opt_call_count <= 3) || (mod(rsma_opt_call_count, 100) == 0);
tick = max(1, floor(numel(zeta_grid)/5));
zeta_max_feasible = local_rho_max_from_harvest(ch, Ps, harvest_cfg);
num_before = numel(zeta_grid);
zeta_grid = zeta_grid(zeta_grid <= zeta_max_feasible + 1e-12);
if isempty(zeta_grid)
    zeta_grid = min(max(zeta_max_feasible, 0), 1);
end
num_after = numel(zeta_grid);
num_skipped = max(0, num_before - num_after);
if do_log
    fprintf('[rsma_opt] call=%d | zeta candidates=%d | feasible zeta_max=%.3f | skipped infeasible=%d | p_step=%.3f | mu candidates=%d\n', ...
        rsma_opt_call_count, num_after, zeta_max_feasible, num_skipped, p_step, numel(mu_grid));
end

for iz = 1:numel(zeta_grid)
    zeta = zeta_grid(iz);
    if do_log && (iz == 1 || iz == numel(zeta_grid) || mod(iz, tick) == 0)
        fprintf('  [rsma_opt] zeta idx %d/%d (zeta=%.3f)\n', iz, numel(zeta_grid), zeta);
    end
    tmp = local_rsma_power(ch, Ps, sic_err, sigma2, zeta, p_step, mu_grid, harvest_cfg);
    if (tmp.max_min_rate > best.max_min_rate + 1e-12) || ...
       (abs(tmp.max_min_rate - best.max_min_rate) <= 1e-12 && tmp.sum_rate > best.sum_rate)
        best = tmp;
        best.zeta = zeta;
    end
end
if do_log
    alpha_c = best.alpha_c; alpha_1 = best.alpha_1; alpha_2 = best.alpha_2;
    is_all_common = best.all_common;
    fprintf('[rsma_opt] best zeta=%.3f | max-min=%.4f | sum-rate=%.4f | mu=%.3f | Pc=%.4g | P1=%.4g | P2=%.4g\n', ...
        best.zeta, best.max_min_rate, best.sum_rate, best.mu, best.Pc, best.P1, best.P2);
    fprintf('          alpha_c=%.3f alpha_1=%.3f alpha_2=%.3f | all-common=%d\n', alpha_c, alpha_1, alpha_2, is_all_common);
end
best.zeta_feasible_max = zeta_max_feasible;
best.infeasible_skip_frac = num_skipped / max(num_before, 1);
best.hit_feasible_bound = abs(best.zeta - zeta_max_feasible) <= 1e-9;
end

function rho_max = local_rho_max_from_harvest(ch, Pt, h)
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

function tf = local_is_all_common(Ps, Pc, P1, P2)
if Ps <= 0
    tf = false;
    return;
end
alpha_c = Pc / Ps;
private_small = (P1 <= 0.025*Ps) && (P2 <= 0.025*Ps);
tf = (alpha_c >= 0.95) && private_small;
end
