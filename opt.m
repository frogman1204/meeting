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

function best = local_rsma_power(ch, Ps, sic_err, sigma2, zeta_fixed, p_step, mu_grid)
if nargin < 6
    p_step = 0.05;
end
if nargin < 7 || isempty(mu_grid)
    mu_grid = 0.1:0.1:0.9;
end

alphas = 0:p_step:1;

best.max_min_rate = -inf;
best.sum_rate = -inf;
best.Pc = 0; best.P1 = 0; best.P2 = 0;
best.zeta = zeta_fixed;
best.mu = 0.5;
best.R1 = 0; best.R2 = 0; best.Rc = 0; best.C1 = 0; best.C2 = 0;

for ac = alphas
    for a1 = alphas
        if ac + a1 > 1, continue; end
        a2 = 1 - ac - a1;
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
            end
        end
    end
end
end

function best = local_rsma_power_zeta(ch, Ps, sic_err, sigma2, zeta_grid, p_step, mu_grid)
if nargin < 6
    p_step = 0.05;
end
if nargin < 7 || isempty(mu_grid)
    mu_grid = 0.1:0.1:0.9;
end

best.max_min_rate = -inf;
best.sum_rate = -inf;
best.Pc = 0; best.P1 = 0; best.P2 = 0;
best.zeta = 0;
best.mu = 0.5;
best.R1 = 0; best.R2 = 0; best.Rc = 0; best.C1 = 0; best.C2 = 0;

for iz = 1:numel(zeta_grid)
    zeta = zeta_grid(iz);
    tmp = local_rsma_power(ch, Ps, sic_err, sigma2, zeta, p_step, mu_grid);
    if (tmp.max_min_rate > best.max_min_rate + 1e-12) || ...
       (abs(tmp.max_min_rate - best.max_min_rate) <= 1e-12 && tmp.sum_rate > best.sum_rate)
        best = tmp;
        best.zeta = zeta;
    end
end
end
