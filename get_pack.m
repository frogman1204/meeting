function p = get_pack(mode_name)
%GET_PACK Grouped getter functions.
% Input:
%   mode_name : 'medium' or 'full'
% Output:
%   p         : parameter struct for the selected mode

switch lower(mode_name)
    case 'medium'
        p = get_default_params_medium();
    case 'full'
        p = get_default_params_full();
    case 'debug'
        p = get_default_params_debug();
    otherwise
        error('Unknown mode: %s', mode_name);
end

end

function p = get_default_params_medium()
p.numMC = 300;
p.Pt_dBm_vec = 10:5:40;
p.sic_err_vec = 0.1:0.2:0.9;
p.csi_err_vec = [0 0.03 0.05 0.1 0.2];
p.blk_loss_dB_vec = 0:10:40;
p.rho_plot_vec = 0:0.1:1;
p.rho_grid = 0:0.05:1;
p.rho_fixed = 0.5;
p.sigma2 = 0.1;
p.rng_seed = 1;
p.Pt_dBm_default = 40;
p.rate_threshold = 0.5;
p.tag_count_vec = [1 2 3 4];
p.harvest_cfg = local_harvest_cfg();
[p.scheme_names, p.scheme_keys] = local_scheme_info();
end

function p = get_default_params_full()
p.numMC = 1000;
p.Pt_dBm_vec = 10:3:40;
p.sic_err_vec = 0.1:0.1:0.9;
p.csi_err_vec = [0 0.01 0.03 0.05 0.1 0.15 0.2];
p.blk_loss_dB_vec = 0:5:40;
p.rho_plot_vec = 0:0.05:1;
p.rho_grid = 0:0.02:1;
p.rho_fixed = 0.5;
p.sigma2 = 0.1;
p.rng_seed = 1;
p.Pt_dBm_default = 40;
p.rate_threshold = 0.5;
p.tag_count_vec = [1 2 3 4 5 6];
p.harvest_cfg = local_harvest_cfg();
[p.scheme_names, p.scheme_keys] = local_scheme_info();
end

function p = get_default_params_debug()
p = get_default_params_medium();
p.numMC = 20;
p.Pt_dBm_vec = [20 40];
p.sic_err_vec = [0.1 0.5];
p.csi_err_vec = [0 0.2];
p.blk_loss_dB_vec = [0 20];
p.rho_plot_vec = [0 0.5 1.0];
p.rho_grid = 0:0.2:1;
end

function h = local_harvest_cfg()
% Harvesting feasibility model for AmBC reflection coefficient.
% E_h = eta_h * (1-rho) * Ps * |hSF|^2 * T >= E_req
h.enable = true;
h.eta_h = 0.6;
h.T = 1.0;
h.E_req = 0.05;
h.P_cir = 0.0; % optional circuit power term

% Optional RSMA debug guard (default disabled / non-restrictive).
h.max_common_frac = 1.0;   % 1.0 keeps all-common allowed
h.min_private_frac = 0.0;  % 0.0 keeps no private-min guard
end

function [names, keys] = local_scheme_info()
keys = {'pure_noma','noma_fixed','noma_opt','pure_rsma','rsma_fixed','rsma_opt'};
names = {'Pure NOMA','NOMA-AmBC (Fixed rho)','NOMA-AmBC (Optimized rho)', ...
    'Pure RSMA','RSMA-AmBC (Fixed rho)','RSMA-AmBC (Optimized rho)'};
end
