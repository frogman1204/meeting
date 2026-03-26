function p = get_default_params_medium()
%GET_DEFAULT_PARAMS_MEDIUM Medium mode settings.

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

[p.scheme_names, p.scheme_keys] = local_scheme_info();

end

function [names, keys] = local_scheme_info()
keys = {'pure_noma','noma_fixed','noma_opt','pure_rsma','rsma_fixed','rsma_opt'};
names = {'Pure NOMA','NOMA-AmBC (Fixed rho)','NOMA-AmBC (Optimized rho)', ...
    'Pure RSMA','RSMA-AmBC (Fixed rho)','RSMA-AmBC (Optimized rho)'};
end
