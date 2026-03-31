function varargout = core(mode, varargin)
%CORE Grouped core functionality.

switch lower(mode)
    case 'ch'
        varargout{1} = local_ch();
    case 'rates'
        [varargout{1}, varargout{2}] = local_rates(varargin{:});
    case 'rates_paper_noma'
        [varargout{1}, varargout{2}] = local_rates_paper_noma(varargin{:});
    case 'rates_paper_oma'
        [varargout{1}, varargout{2}] = local_rates_paper_oma(varargin{:});
    case 'rates_rsma'
        [varargout{1}, varargout{2}, varargout{3}] = local_rates_rsma(varargin{:});
    otherwise
        error('Unknown core mode: %s', mode);
end

end

function ch = local_ch()
ch.hSR1 = (randn + 1i*randn)/sqrt(2);
ch.hSR2 = (randn + 1i*randn)/sqrt(2);
ch.hSF = (randn + 1i*randn)/sqrt(2);
ch.gFR1 = (randn + 1i*randn)/sqrt(2);
ch.gFR2 = (randn + 1i*randn)/sqrt(2);
end

function [R1, R2] = local_rates(ch, Pt, sic_err, sigma2, rho, xi)
if nargin < 6, xi = 0.3; end
xi = min(max(xi, 1e-3), 1-1e-3);
g1 = abs(ch.hSR1)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR2)^2;
sinr1 = Pt*xi*g1/(Pt*(1-xi)*g1*sic_err + sigma2);
sinr2 = Pt*(1-xi)*g2/(Pt*xi*g2 + sigma2);
R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);
end

function [R1, R2] = local_rates_paper_noma(ch, Pt, sic_err, sigma2, rho, xi)
xi = min(max(xi, 1e-3), 1-1e-3);
A1 = abs(ch.hSR1)^2;
A2 = abs(ch.hSR2)^2;
B1 = abs(ch.hSF)^2 * abs(ch.gFR1)^2;
B2 = abs(ch.hSF)^2 * abs(ch.gFR2)^2;
G1 = A1 + rho * B1;
G2 = A2 + rho * B2;

% Paper-mode convention: SIC residual term uses A1 in near-user denominator.
sinr1 = Pt * xi * G1 / (Pt * (1 - xi) * A1 * sic_err + sigma2);
sinr2 = Pt * (1 - xi) * G2 / (Pt * xi * G2 + sigma2);
R1 = log2(1 + sinr1);
R2 = log2(1 + sinr2);
end

function [R1, R2] = local_rates_paper_oma(ch, Pt, sigma2, rho)
G1 = abs(ch.hSR1)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR1)^2;
G2 = abs(ch.hSR2)^2 + rho*abs(ch.hSF)^2*abs(ch.gFR2)^2;
R1 = 0.5 * log2(1 + Pt * G1 / sigma2);
R2 = 0.5 * log2(1 + Pt * G2 / sigma2);
end

function [R1, R2, out] = local_rates_rsma(ch, Ps, sic_err, sigma2, rho, rsma_cfg)
if nargin < 6 || isempty(rsma_cfg), rsma_cfg = struct(); end
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
if sumP > 0
    scale = Ps / sumP;
    Pc = Pc * scale; P1 = P1 * scale; P2 = P2 * scale;
end

g1 = abs(ch.hSR1)^2 + rho * abs(ch.hSF)^2 * abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + rho * abs(ch.hSF)^2 * abs(ch.gFR2)^2;

sinr_c1 = Pc * g1 / (P1 * g1 + P2 * g1 + sic_err * Pc * g1 + sigma2);
sinr_c2 = Pc * g2 / (P1 * g2 + P2 * g2 + sic_err * Pc * g2 + sigma2);
Rc_u1 = log2(1 + sinr_c1); Rc_u2 = log2(1 + sinr_c2); Rc = min(Rc_u1, Rc_u2);
sinr_p1 = P1 * g1 / (P2 * g1 * sic_err + sigma2);
sinr_p2 = P2 * g2 / (P1 * g2 * sic_err + sigma2);

mu = 0.5; if isfield(rsma_cfg, 'mu'), mu = rsma_cfg.mu; end
mu = min(max(mu, 0), 1);
C1 = mu * Rc; C2 = (1 - mu) * Rc;

R1 = C1 + log2(1 + sinr_p1);
R2 = C2 + log2(1 + sinr_p2);

out.sinr_common_u1 = sinr_c1; out.sinr_common_u2 = sinr_c2;
out.sinr_private_u1 = sinr_p1; out.sinr_private_u2 = sinr_p2;
out.common_rate_u1 = Rc_u1; out.common_rate_u2 = Rc_u2; out.common_rate = Rc;
out.C1 = C1; out.C2 = C2;
out.Pc = Pc; out.P1 = P1; out.P2 = P2; out.mu = mu; out.rho = rho;
out.sic_err_used = sic_err; out.g1 = g1; out.g2 = g2;
end
