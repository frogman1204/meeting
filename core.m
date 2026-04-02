function varargout = core(mode, varargin)
%CORE Grouped core functionality.

switch lower(mode)
    case 'ch'
        if nargin >= 2, p = varargin{1}; else, p = struct(); end
        varargout{1} = local_ch(p);
    case 'rates'
        [varargout{1}, varargout{2}, varargout{3}] = local_rates(varargin{:});
    case 'rates_paper_noma'
        [varargout{1}, varargout{2}] = local_rates_paper_noma(varargin{:});
    case 'rates_paper_oma'
        [varargout{1}, varargout{2}] = local_rates_paper_oma(varargin{:});
    case 'rates_rsma'
        [varargout{1}, varargout{2}, varargout{3}] = local_rates_rsma(varargin{:});
    case 'rates_sdma'
        [varargout{1}, varargout{2}, varargout{3}] = local_rates_sdma(varargin{:});
    otherwise
        error('Unknown core mode: %s', mode);
end

end

function ch = local_ch(p)
M = local_get_or(local_get_or(p,'miso_cfg',struct()), 'M', 4);
% MISO true channels
ray = @(m,n) (randn(m,n) + 1i*randn(m,n))/sqrt(2);
ch.h1_true = ray(M,1);
ch.h2_true = ray(M,1);
Kbt = 5; % LOS-dominant BS->Tag
ch.hBT_true = sqrt(Kbt/(Kbt+1))*ones(M,1)/sqrt(M) + sqrt(1/(Kbt+1))*ray(M,1);
Kt = 3;
ch.gT1_true = sqrt(Kt/(Kt+1)) + sqrt(1/(Kt+1))*ray(1,1);
ch.gT2_true = sqrt(Kt/(Kt+1)) + sqrt(1/(Kt+1))*ray(1,1);
% Estimated channels init = true; CSI mismatch applied in apply_pack.
ch.h1_est = ch.h1_true; ch.h2_est = ch.h2_true; ch.hBT_est = ch.hBT_true;
ch.gT1_est = ch.gT1_true; ch.gT2_est = ch.gT2_true;
% legacy aliases
ch.hSR1 = norm(ch.h1_true); ch.hSR2 = norm(ch.h2_true); ch.hSF = norm(ch.hBT_true);
ch.gFR1 = ch.gT1_true; ch.gFR2 = ch.gT2_true;
end

function [R1, R2, out] = local_rates(ch, Pt, sic_err, sigma2, rho, xi, ambc_cfg)
if nargin < 6, xi = 0.3; end
if nargin < 7 || isempty(ambc_cfg), ambc_cfg = local_default_ambc_cfg(); end
xi = min(max(xi, 1e-3), 1-1e-3);

if isfield(ch, 'h1_true')
    [g1, g2, c1, c2] = local_miso_effective_terms(ch, Pt, rho, ambc_cfg);
else
    g1 = abs(ch.hSR1)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR1)^2;
    g2 = abs(ch.hSR2)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR2)^2;
    c1 = g1; c2 = g2;
end

sinr1 = Pt*xi*g1/(Pt*(1-xi)*c1*sic_err + sigma2);
sinr2 = Pt*(1-xi)*g2/(Pt*xi*c2 + sigma2);
R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);
tag_ber = local_tag_ook_ber_samples(ch, Pt*xi, Pt*(1-xi), 0, rho, ambc_cfg);
out.g1 = g1; out.g2 = g2; out.c1 = c1; out.c2 = c2; out.tag_ber = tag_ber;
end

function [R1, R2, out] = local_rates_sdma(ch, Pt, sigma2, rho, xi, ambc_cfg)
if nargin < 5 || isempty(xi), xi = 0.5; end
if nargin < 6 || isempty(ambc_cfg), ambc_cfg = local_default_ambc_cfg(); end
xi = min(max(xi, 1e-3), 1-1e-3);
P1 = Pt*xi; P2 = Pt*(1-xi);
if isfield(ch,'h1_true')
    w1 = ch.h1_est / max(norm(ch.h1_est), eps);
    w2 = ch.h2_est / max(norm(ch.h2_est), eps);
    wT = ch.hBT_est / max(norm(ch.hBT_est), eps);
    d11 = abs(ch.h1_true' * w1)^2;
    d22 = abs(ch.h2_true' * w2)^2;
    i12 = abs(ch.h1_true' * w2)^2;
    i21 = abs(ch.h2_true' * w1)^2;
    [gbar, ~, ~] = local_tag_modulation_params(ambc_cfg);
    ambc_i1 = rho * gbar * abs(ch.gT1_true * (ch.hBT_true' * wT))^2;
    ambc_i2 = rho * gbar * abs(ch.gT2_true * (ch.hBT_true' * wT))^2;
    sinr1 = P1*d11 / (P2*i12 + Pt*ambc_i1 + sigma2);
    sinr2 = P2*d22 / (P1*i21 + Pt*ambc_i2 + sigma2);
else
    sinr1 = P1*abs(ch.hSR1)^2 / (P2*abs(ch.hSR1)^2 + sigma2);
    sinr2 = P2*abs(ch.hSR2)^2 / (P1*abs(ch.hSR2)^2 + sigma2);
end
R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);
out.tag_ber = local_tag_ook_ber_samples(ch, P1, P2, 0, rho, ambc_cfg);
out.xi = xi;
end

function [R1, R2] = local_rates_paper_noma(ch, Pt, sic_err, sigma2, rho, xi)
xi = min(max(xi, 1e-3), 1-1e-3);
A1 = abs(ch.hSR1)^2;
A2 = abs(ch.hSR2)^2;
B1 = abs(ch.hSF)^2 * abs(ch.gFR1)^2;
B2 = abs(ch.hSF)^2 * abs(ch.gFR2)^2;
G1 = A1 + rho * B1;
G2 = A2 + rho * B2;
sinr1 = Pt * xi * G1 / (Pt * (1 - xi) * A1 * sic_err + sigma2);
sinr2 = Pt * (1 - xi) * G2 / (Pt * xi * G2 + sigma2);
R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);
end

function [R1, R2] = local_rates_paper_oma(ch, Pt, sigma2, rho)
A1 = abs(ch.hSR1)^2;
A2 = abs(ch.hSR2)^2;
B1 = rho * abs(ch.hSF)^2 * abs(ch.gFR1)^2;
B2 = rho * abs(ch.hSF)^2 * abs(ch.gFR2)^2;
R1 = 0.5 * log2(1 + Pt * (A1 + B1) / sigma2);
R2 = 0.5 * log2(1 + Pt * (A2 + B2) / sigma2);
end

function [R1, R2, out] = local_rates_rsma(ch, Ps, sic_err, sigma2, rho, rsma_cfg)
if nargin < 6 || isempty(rsma_cfg), rsma_cfg = struct(); end
if isfield(rsma_cfg, 'ambc_cfg'), ambc_cfg = rsma_cfg.ambc_cfg; else, ambc_cfg = local_default_ambc_cfg(); end
if isfield(rsma_cfg, 'Pc') && isfield(rsma_cfg, 'P1') && isfield(rsma_cfg, 'P2')
    Pc = rsma_cfg.Pc; P1 = rsma_cfg.P1; P2 = rsma_cfg.P2;
else
    alpha_c = 0.20; alpha_1 = 0.40; alpha_2 = 1 - alpha_c - alpha_1;
    if isfield(rsma_cfg, 'alpha_c'), alpha_c = rsma_cfg.alpha_c; end
    if isfield(rsma_cfg, 'alpha_1'), alpha_1 = rsma_cfg.alpha_1; end
    if isfield(rsma_cfg, 'alpha_2'), alpha_2 = rsma_cfg.alpha_2; end
    Pc = Ps * alpha_c; P1 = Ps * alpha_1; P2 = Ps * alpha_2;
end
sumP = Pc + P1 + P2;
if sumP > 0, scale = Ps / sumP; Pc = Pc * scale; P1 = P1 * scale; P2 = P2 * scale; end

if isfield(ch,'h1_true')
    [g1, g2, ~, ~] = local_miso_effective_terms(ch, Ps, rho, ambc_cfg);
else
    g1 = abs(ch.hSR1)^2 + rho * abs(ch.hSF)^2 * abs(ch.gFR1)^2;
    g2 = abs(ch.hSR2)^2 + rho * abs(ch.hSF)^2 * abs(ch.gFR2)^2;
end

sinr_c1 = Pc * g1 / (P1 * g1 + P2 * g1 + sic_err * Pc * g1 + sigma2);
sinr_c2 = Pc * g2 / (P1 * g2 + P2 * g2 + sic_err * Pc * g2 + sigma2);
Rc_u1 = log2(1 + sinr_c1); Rc_u2 = log2(1 + sinr_c2); Rc = min(Rc_u1, Rc_u2);
sinr_p1 = P1 * g1 / (P2 * g1 * sic_err + sigma2);
sinr_p2 = P2 * g2 / (P1 * g2 * sic_err + sigma2);
mu = 0.5; if isfield(rsma_cfg, 'mu'), mu = rsma_cfg.mu; end
mu = min(max(mu, 0), 1); C1 = mu * Rc; C2 = (1 - mu) * Rc;
R1 = C1 + log2(1 + sinr_p1); R2 = C2 + log2(1 + sinr_p2);
tag_ber = local_tag_ook_ber_samples(ch, P1, P2, Pc, rho, ambc_cfg);
out.sinr_common_u1 = sinr_c1; out.sinr_common_u2 = sinr_c2;
out.sinr_private_u1 = sinr_p1; out.sinr_private_u2 = sinr_p2;
out.common_rate_u1 = Rc_u1; out.common_rate_u2 = Rc_u2; out.common_rate = Rc;
out.C1 = C1; out.C2 = C2; out.Pc = Pc; out.P1 = P1; out.P2 = P2; out.mu = mu; out.rho = rho;
out.sic_err_used = sic_err; out.g1 = g1; out.g2 = g2; out.tag_ber = tag_ber;
end

function [g1, g2, c1, c2] = local_miso_effective_terms(ch, Pt, rho, ambc_cfg)
% Design beams from estimated channels, evaluate on true channels.
w1 = ch.h1_est / max(norm(ch.h1_est), eps);
w2 = ch.h2_est / max(norm(ch.h2_est), eps);
wT = ch.hBT_est / max(norm(ch.hBT_est), eps);
d11 = abs(ch.h1_true' * w1)^2; d12 = abs(ch.h1_true' * w2)^2;
d22 = abs(ch.h2_true' * w2)^2; d21 = abs(ch.h2_true' * w1)^2;

if strcmpi(local_get_or(ambc_cfg,'mode','reflection_only'),'ook_modulated')
    Gamma = 0.5*(local_get_or(ambc_cfg,'Gamma0',0) + local_get_or(ambc_cfg,'Gamma1',local_get_or(ambc_cfg,'beta_reflect',0.5)));
else
    Gamma = local_get_or(ambc_cfg,'beta_reflect',0.5);
end

r1 = abs(ch.gT1_true * (ch.hBT_true' * wT))^2;
r2 = abs(ch.gT2_true * (ch.hBT_true' * wT))^2;
ambc1 = rho * abs(Gamma)^2 * r1;
ambc2 = rho * abs(Gamma)^2 * r2;

g1 = d11 + ambc1;
g2 = d22 + ambc2;
c1 = d12 + 1e-6;
c2 = d21 + 1e-6;

end

function a = local_default_ambc_cfg()
a = struct('mode','reflection_only','beta_reflect',0.5,'Gamma0',0,'Gamma1',0.5,'bits_per_symbol',1,'ber_max_bits',1e6,'ber_min_errors',100);
end


function ber = local_tag_ook_ber_samples(ch, P1, P2, Pc, rho, ambc_cfg)
if ~isfield(ch,'h1_true') || ~strcmpi(local_get_or(ambc_cfg,'mode','reflection_only'),'ook_modulated')
    ber = NaN; return;
end
max_bits = round(local_get_or(ambc_cfg, 'ber_max_bits', 1e6));
min_err = round(local_get_or(ambc_cfg, 'ber_min_errors', 100));
if max_bits <= 0, ber = NaN; return; end
Gamma0 = local_get_or(ambc_cfg, 'Gamma0', 0.0);
Gamma1 = local_get_or(ambc_cfg, 'Gamma1', local_get_or(ambc_cfg, 'beta_reflect', 0.5));
w1 = ch.h1_est / max(norm(ch.h1_est), eps);
w2 = ch.h2_est / max(norm(ch.h2_est), eps);
wT = ch.hBT_est / max(norm(ch.hBT_est), eps);
wC = (w1 + w2); wC = wC / max(norm(wC), eps);
a1 = ch.gT1_true * (ch.hBT_true' * wT);
a2 = ch.gT2_true * (ch.hBT_true' * wT);
errs = 0; n = 0; blk = min(10000, max_bits);
while n < max_bits && errs < min_err
    nb = min(blk, max_bits - n);
    b = randi([0,1], nb, 1);
    s1 = (randn(nb,1)+1i*randn(nb,1))/sqrt(2);
    s2 = (randn(nb,1)+1i*randn(nb,1))/sqrt(2);
    sc = (randn(nb,1)+1i*randn(nb,1))/sqrt(2);
    st = (randn(nb,1)+1i*randn(nb,1))/sqrt(2);
    gam = Gamma0*(1-b) + Gamma1*b;
    n1 = (randn(nb,1)+1i*randn(nb,1))/sqrt(2);
    n2 = (randn(nb,1)+1i*randn(nb,1))/sqrt(2);
    d1 = sqrt(P1)*(ch.h1_true' * w1).*s1 + sqrt(P2)*(ch.h1_true' * w2).*s2 + sqrt(max(Pc,0))*(ch.h1_true' * wC).*sc;
    d2 = sqrt(P1)*(ch.h2_true' * w1).*s1 + sqrt(P2)*(ch.h2_true' * w2).*s2 + sqrt(max(Pc,0))*(ch.h2_true' * wC).*sc;
    y1 = d1 + sqrt(rho)*sqrt(max(P1+P2+Pc,0))*(a1.*gam).*st + n1;
    y2 = d2 + sqrt(rho)*sqrt(max(P1+P2+Pc,0))*(a2.*gam).*st + n2;
    z = real(conj(st) .* (y1 + y2) / 2);
    mu0 = sqrt(rho)*sqrt(max(P1+P2+Pc,0))*real((a1 + a2)/2 * Gamma0);
    mu1 = sqrt(rho)*sqrt(max(P1+P2+Pc,0))*real((a1 + a2)/2 * Gamma1);
    bhat = z > (mu0 + mu1)/2;
    errs = errs + sum(bhat ~= b);
    n = n + nb;
end
ber = errs / max(n,1);
end

function [gbar, Gamma0, Gamma1] = local_tag_modulation_params(ambc_cfg)
if strcmpi(local_get_or(ambc_cfg,'mode','reflection_only'),'ook_modulated')
    Gamma0 = local_get_or(ambc_cfg,'Gamma0',0);
    Gamma1 = local_get_or(ambc_cfg,'Gamma1',local_get_or(ambc_cfg,'beta_reflect',0.5));
    gbar = 0.5*(abs(Gamma0)^2 + abs(Gamma1)^2);
else
    Gamma0 = local_get_or(ambc_cfg,'beta_reflect',0.5);
    Gamma1 = Gamma0;
    gbar = abs(Gamma0)^2;
end
end

function v = local_get_or(s, k, d)
if isfield(s, k), v = s.(k); else, v = d; end
end
