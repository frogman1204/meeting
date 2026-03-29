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

function best = local_rsma_power(ch, Ps, sic_err, sigma2, zeta_fixed, p_step)
if nargin < 6
    p_step = 0.05;
end

g1 = abs(ch.hSR1)^2 + zeta_fixed * abs(ch.hSF)^2 * abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + zeta_fixed * abs(ch.hSF)^2 * abs(ch.gFR2)^2;

alphas = 0:p_step:1;

best.sum_rate = -inf;
best.Pc = 0; best.P1 = 0; best.P2 = 0;
best.zeta = zeta_fixed;
best.R1 = 0; best.R2 = 0; best.Rc = 0; best.C1 = 0; best.C2 = 0;

for ac = alphas
    for a1 = alphas
        if ac + a1 > 1, continue; end
        a2 = 1 - ac - a1;
        Pc = Ps * ac; P1 = Ps * a1; P2 = Ps * a2;

        sinr_c1 = Pc*g1 / (P1*g1 + P2*g1 + sigma2);
        sinr_c2 = Pc*g2 / (P1*g2 + P2*g2 + sigma2);
        Rc = min(log2(1 + sinr_c1), log2(1 + sinr_c2));

        C1 = 0.5 * Rc; C2 = 0.5 * Rc;
        sinr_p1 = P1*g1 / (P2*g1*sic_err + sigma2);
        sinr_p2 = P2*g2 / (P1*g2 + sigma2);
        R1 = C1 + log2(1 + sinr_p1);
        R2 = C2 + log2(1 + sinr_p2);
        sum_rate = R1 + R2;

        if sum_rate > best.sum_rate
            best.sum_rate = sum_rate;
            best.Pc = Pc; best.P1 = P1; best.P2 = P2;
            best.R1 = R1; best.R2 = R2; best.Rc = Rc; best.C1 = C1; best.C2 = C2;
        end
    end
end
end

function best = local_rsma_power_zeta(ch, Ps, sic_err, sigma2, zeta_grid, p_step)
if nargin < 6
    p_step = 0.05;
end

best.sum_rate = -inf;
best.Pc = 0; best.P1 = 0; best.P2 = 0;
best.zeta = 0;
best.R1 = 0; best.R2 = 0; best.Rc = 0; best.C1 = 0; best.C2 = 0;

for iz = 1:numel(zeta_grid)
    zeta = zeta_grid(iz);
    tmp = local_rsma_power(ch, Ps, sic_err, sigma2, zeta, p_step);
    if tmp.sum_rate > best.sum_rate
        best = tmp;
        best.zeta = zeta;
    end
end
end
