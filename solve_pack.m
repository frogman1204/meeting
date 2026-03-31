function met = solve_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, varargin)
%SOLVE_PACK Router between NOMA baseline and RSMA proposed modules.

if nargin >= 8, harvest_cfg = varargin{1}; else, harvest_cfg = struct(); end
if nargin >= 9, xi_grid = varargin{2}; else, xi_grid = 0.05:0.05:0.95; end
if nargin >= 10, experiment_mode = varargin{3}; else, experiment_mode = 'research_rsma'; end

switch lower(mode)
    case 'pure_noma'
        met = noma_baseline_pack('pure', ch, Pt, sic_err, sigma2, 0, rate_threshold, harvest_cfg, xi_grid, experiment_mode);
    case 'noma_fixed'
        met = noma_baseline_pack('fixed', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg, xi_grid, experiment_mode);
    case 'noma_opt'
        met = noma_baseline_pack('opt', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg, xi_grid, experiment_mode);
    case 'oma_ambc'
        met = noma_baseline_pack('oma', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg, xi_grid, experiment_mode);
    case 'pure_rsma'
        met = rsma_proposed_pack('pure', ch, Pt, sic_err, sigma2, 0, rate_threshold, harvest_cfg);
    case 'rsma_fixed'
        met = rsma_proposed_pack('fixed', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg);
    case 'rsma_opt'
        met = rsma_proposed_pack('opt', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold, harvest_cfg);
    otherwise
        error('Unknown solve mode: %s', mode);
end

end
