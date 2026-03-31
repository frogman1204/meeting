function p = get_pack(mode_name)
%GET_PACK Grouped getter functions.
% Input:
%   mode_name : medium/full/debug/paper_reproduction/research_rsma
% Output:
%   p         : parameter struct for the selected mode

switch lower(mode_name)
    case 'medium'
        p = get_default_params_medium();
    case 'full'
        p = get_default_params_full();
    case 'debug'
        p = get_default_params_debug();
    case 'paper_reproduction'
        p = get_default_params_paper_reproduction();
    case 'research_rsma'
        p = get_default_params_full();
        p.experiment_mode = 'research_rsma';
    otherwise
        error('Unknown mode: %s', mode_name);
end

end

function p = get_default_params_medium()
p = local_common_defaults();
p.experiment_mode = 'research_rsma';
p.numMC = 300;
p.Pt_dBm_vec = 10:5:40;
p.sic_err_vec = 0.1:0.2:0.9;
p.csi_err_vec = [0 0.03 0.05 0.1 0.2];
p.blk_loss_dB_vec = 0:10:40;
p.rho_plot_vec = 0:0.1:1;
p.rho_grid = 0:0.05:1;
p.xi_grid = 0.05:0.05:0.95;
p.tag_count_vec = [1 2 3 4];
[p.scheme_names, p.scheme_keys] = local_scheme_info('research_rsma');
end

function p = get_default_params_full()
p = local_common_defaults();
p.experiment_mode = 'research_rsma';
p.numMC = 1000;
p.Pt_dBm_vec = 10:3:40;
p.sic_err_vec = 0.1:0.1:0.9;
p.csi_err_vec = [0 0.01 0.03 0.05 0.1 0.15 0.2];
p.blk_loss_dB_vec = 0:5:40;
p.rho_plot_vec = 0:0.05:1;
p.rho_grid = 0:0.02:1;
p.xi_grid = 0.02:0.02:0.98;
p.tag_count_vec = [1 2 3 4 5 6];
[p.scheme_names, p.scheme_keys] = local_scheme_info('research_rsma');
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
p.xi_grid = 0.1:0.1:0.9;
p.enabled_sweeps = {'power','rho'};
p.harvest_cfg.rsma_p_step = 0.2;
p.harvest_cfg.mu_grid = [0.2 0.5 0.8];
end

function p = get_default_params_paper_reproduction()
p = local_common_defaults();
p.experiment_mode = 'paper_reproduction';
p.numMC = 1000;
p.Pt_dBm_vec = 10:3:40;
p.sic_err_vec = 0.1:0.1:0.9;
p.csi_err_vec = 0;
p.blk_loss_dB_vec = 0;
p.rho_plot_vec = 0:0.02:1;
p.rho_grid = 0:0.02:1;
p.rho_fixed = 0.5;
p.xi_grid = 0.02:0.02:0.5;
p.sigma2 = 0.1;
p.rng_seed = 1;
p.harvest_cfg.enable = false;
p.enabled_sweeps = {'power','sic'};
p.tag_count_vec = [];
[p.scheme_names, p.scheme_keys] = local_scheme_info('paper_reproduction');
end

function p = local_common_defaults()
p.Pt_dBm_default = 40;
p.rho_fixed = 0.5;
p.rate_threshold = 0.5;
p.sigma2 = 0.1;
p.rng_seed = 1;
p.harvest_cfg = local_harvest_cfg();
p.plot_cfg = local_plot_cfg();
end

function h = local_harvest_cfg()
h.enable = true;
h.eta_h = 0.6;
h.T = 1.0;
h.E_req = 0.05;
h.P_cir = 0.0;
h.max_common_frac = 1.0;
h.min_private_frac = 0.0;
h.rsma_p_step = 0.1;
h.mu_grid = 0.1:0.1:0.9;
end

function c = local_plot_cfg()
c.plot_power_mm = true;
c.plot_power_sum = true;
c.plot_blockage_mm = true;
c.plot_csi = true;
c.plot_rho = true;
c.plot_sic = true;
c.plot_rsma_diag = true;
c.plot_tags = false;
end

function [names, keys] = local_scheme_info(experiment_mode)
switch lower(experiment_mode)
    case 'paper_reproduction'
        keys = {'noma_opt','noma_fixed','pure_noma','oma_ambc'};
        names = {'Proposed NOMA-AmBC','Benchmark NOMA-AmBC (fixed rho)','Pure NOMA','OMA-AmBC'};
    otherwise
        keys = {'pure_noma','noma_fixed','noma_opt','pure_rsma','rsma_fixed','rsma_opt'};
        names = {'Pure NOMA','NOMA-AmBC (Fixed rho)','NOMA-AmBC (Optimized rho)', ...
            'Pure RSMA','RSMA-AmBC (Fixed rho)','RSMA-AmBC (Optimized rho)'};
end
end
