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
    case 'rsma_wmmse_zeta'
        out = local_rsma_wmmse_zeta(varargin{:});
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

function best = local_rsma_wmmse_zeta(ch, Ps, sic_err, sigma2, zeta_grid, harvest_cfg, ambc_cfg)
% Minimal RSMA WMMSE with rho search. Simplified but true alternating WMMSE.
zeta_max_feasible = local_rho_max_from_harvest(ch, Ps, harvest_cfg);
num_before = numel(zeta_grid);
zeta_grid = zeta_grid(zeta_grid <= zeta_max_feasible + 1e-12);
if isempty(zeta_grid), zeta_grid = min(max(zeta_max_feasible, 0), 1); end
num_skipped = max(0, num_before - numel(zeta_grid));

best.max_min_rate = -inf; best.sum_rate = -inf;
for iz = 1:numel(zeta_grid)
    rho = zeta_grid(iz);
    tmp = local_rsma_wmmse_single_rho(ch, Ps, sigma2, rho, sic_err, ambc_cfg);
    if (tmp.max_min_rate > best.max_min_rate + 1e-12) || ...
       (abs(tmp.max_min_rate - best.max_min_rate) <= 1e-12 && tmp.sum_rate > best.sum_rate)
        best = tmp; best.zeta = rho;
    end
end
best.zeta_feasible_max = zeta_max_feasible;
best.infeasible_skip_frac = num_skipped / max(num_before, 1);
best.hit_feasible_bound = abs(best.zeta - zeta_max_feasible) <= 1e-9;
end

function out = local_rsma_wmmse_single_rho(ch, Ps, sigma2, rho, sic_err, ambc_cfg)
if ~isfield(ch,'h1_true')
    tmp = local_rsma_power(ch, Ps, sic_err, sigma2, rho, 0.1, 0.1:0.1:0.9, struct());
    out = tmp; return;
end
h1 = local_effective_channel(ch.h1_true, ch.hBT_true, ch.gT1_true, rho, ambc_cfg);
h2 = local_effective_channel(ch.h2_true, ch.hBT_true, ch.gT2_true, rho, ambc_cfg);
h1e = local_effective_channel(ch.h1_est, ch.hBT_est, ch.gT1_est, rho, ambc_cfg);
h2e = local_effective_channel(ch.h2_est, ch.hBT_est, ch.gT2_est, rho, ambc_cfg);
M = numel(h1e);
v1 = sqrt(Ps/3) * h1e / max(norm(h1e), eps);
v2 = sqrt(Ps/3) * h2e / max(norm(h2e), eps);
vc = sqrt(Ps/3) * (h1e + h2e) / max(norm(h1e+h2e), eps);
V = [vc v1 v2];
max_iter = 25; tol = 1e-4; prev_obj = -inf;
for it = 1:max_iter
    [gc1, ec1, uc1, g11, e11, u11, rc1, rp1] = local_user_wmmse_terms(h1e, V, sigma2, sic_err, 1);
    [gc2, ec2, uc2, g22, e22, u22, rc2, rp2] = local_user_wmmse_terms(h2e, V, sigma2, sic_err, 2);
    A = uc1*abs(gc1)^2*(h1e*h1e') + uc2*abs(gc2)^2*(h2e*h2e') + ...
        u11*abs(g11)^2*(h1e*h1e') + u22*abs(g22)^2*(h2e*h2e');
    B = [uc1*conj(gc1)*h1e + uc2*conj(gc2)*h2e, u11*conj(g11)*h1e, u22*conj(g22)*h2e];
    Vnew = local_update_precoders(A, B, Ps, M);
    [R1, R2, ~, ~, ~] = local_rsma_rates_from_beams(h1, h2, Vnew, sigma2, sic_err);
    obj = min(R1,R2);
    if it <= 3 || it == max_iter
        fprintf('[rsma_wmmse] iter=%d rho=%.3f obj=%.4f\n', it, rho, obj);
    end
    if abs(obj - prev_obj) <= tol, V = Vnew; break; end
    prev_obj = obj; V = Vnew;
end
[R1, R2, Rc, C1, C2] = local_rsma_rates_from_beams(h1, h2, V, sigma2, sic_err);
Pc = norm(V(:,1))^2; P1 = norm(V(:,2))^2; P2 = norm(V(:,3))^2;
sumP = max(Pc+P1+P2, eps);
out.R1 = R1; out.R2 = R2; out.max_min_rate = min(R1,R2); out.sum_rate = R1 + R2;
out.Pc = Pc; out.P1 = P1; out.P2 = P2;
out.alpha_c = Pc/sumP; out.alpha_1 = P1/sumP; out.alpha_2 = P2/sumP;
out.mu = C1/max(Rc,eps); out.C1 = C1; out.C2 = C2; out.Rc = Rc;
out.common_rate = Rc; out.common_rate_u1 = Rc; out.common_rate_u2 = Rc;
out.sinr_common_u1 = 2^Rc - 1; out.sinr_common_u2 = 2^Rc - 1;
out.sinr_private_u1 = 2^(R1-C1)-1; out.sinr_private_u2 = 2^(R2-C2)-1;
out.all_common = local_is_all_common(Ps, Pc, P1, P2);
end

function h = local_effective_channel(hd, hBT, gTk, rho, ambc_cfg)
if strcmpi(local_get_or(ambc_cfg,'mode','reflection_only'),'ook_modulated')
    g0 = local_get_or(ambc_cfg,'Gamma0',0); g1 = local_get_or(ambc_cfg,'Gamma1',local_get_or(ambc_cfg,'beta_reflect',0.5));
    gbar = 0.5*(g0+g1);
else
    gbar = local_get_or(ambc_cfg,'beta_reflect',0.5);
end
h = hd + sqrt(max(rho,0)) * (gTk * gbar) * hBT;
end

function [gc, ec, uc, gp, ep, up, rc, rp] = local_user_wmmse_terms(h, V, sigma2, sic_err, user_idx)
tc = abs(h' * V(:,1))^2 + abs(h' * V(:,2))^2 + abs(h' * V(:,3))^2 + sigma2;
gc = (h' * V(:,1)) / max(tc, eps);
ec = max(1e-9, 1 - 2*real(gc*(h' * V(:,1))) + abs(gc)^2*tc);
uc = 1/ec;
if user_idx == 1
    tp = abs(h' * V(:,2))^2 + abs(h' * V(:,3))^2 + sic_err*abs(h' * V(:,1))^2 + sigma2;
    gp = (h' * V(:,2)) / max(tp, eps);
    sig = V(:,2);
else
    tp = abs(h' * V(:,3))^2 + abs(h' * V(:,2))^2 + sic_err*abs(h' * V(:,1))^2 + sigma2;
    gp = (h' * V(:,3)) / max(tp, eps);
    sig = V(:,3);
end
ep = max(1e-9, 1 - 2*real(gp*(h' * sig)) + abs(gp)^2*tp);
up = 1/ep;
rc = -log2(ec); rp = -log2(ep);
end

function V = local_update_precoders(A, B, Ps, M)
I = eye(M);
lam_lo = 0; lam_hi = 1;
for k = 1:30
    Vt = (A + lam_hi*I) \ B;
    if sum(abs(Vt(:)).^2) <= Ps, break; end
    lam_hi = lam_hi * 2;
end
for k = 1:35
    lam = 0.5*(lam_lo + lam_hi);
    Vt = (A + lam*I) \ B;
    p = sum(abs(Vt(:)).^2);
    if p > Ps, lam_lo = lam; else, lam_hi = lam; end
end
V = (A + lam_hi*I) \ B;
end

function [R1, R2, Rc, C1, C2] = local_rsma_rates_from_beams(h1, h2, V, sigma2, sic_err)
sc1 = abs(h1' * V(:,1))^2; sp11 = abs(h1' * V(:,2))^2; sp12 = abs(h1' * V(:,3))^2;
sc2 = abs(h2' * V(:,1))^2; sp22 = abs(h2' * V(:,3))^2; sp21 = abs(h2' * V(:,2))^2;
sinr_c1 = sc1 / max(sp11 + sp12 + sigma2, eps);
sinr_c2 = sc2 / max(sp22 + sp21 + sigma2, eps);
Rc = min(log2(1+sinr_c1), log2(1+sinr_c2));
sinr_p1 = sp11 / max(sp12 + sic_err*sc1 + sigma2, eps);
sinr_p2 = sp22 / max(sp21 + sic_err*sc2 + sigma2, eps);
Rp1 = log2(1+sinr_p1); Rp2 = log2(1+sinr_p2);
if Rc <= 1e-12
    mu = 0.5;
else
    mu = (Rp2 - Rp1 + Rc) / max(2*Rc, eps);
    mu = min(max(mu, 0), 1);
end
C1 = mu*Rc; C2 = (1-mu)*Rc;
R1 = Rp1 + C1; R2 = Rp2 + C2;
end
