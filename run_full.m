%RUN_FULL Run full exploratory mode.

params = get_default_params_full();
out_dir = run_all_figures_core(params, 'full');
fprintf('Saved folder: %s\n', out_dir);
fprintf('Exploratory figure generation complete.\n');

% NEXT STEP
% 1) full BER implementation
% 2) faster rho optimization
% 3) more accurate RSMA optimization
% 4) tag selection extension
% 5) paper-ready figure filtering
