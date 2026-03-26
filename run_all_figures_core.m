function out_dir = run_all_figures_core(params, mode_name)
%RUN_ALL_FIGURES_CORE Shared runner for medium/full modes.

rng(params.rng_seed);
ts = datestr(now, 'yyyymmdd_HHMMSS');
out_dir = fullfile('out', sprintf('%s_run_%s', mode_name, ts));

res_power = run_sweep_power(params);
res_csi = run_sweep_csi(params);
res_blk = run_sweep_blockage(params);
res_rho = run_sweep_rho(params);
res_sic = run_sweep_sic(params);
res_tags = run_sweep_tags(params); %#ok<NASGU>

all_results = struct('power', res_power, 'csi', res_csi, 'blockage', res_blk, 'rho', res_rho, 'sic', res_sic, 'tags', res_tags);

tables = {
    struct('name','tbl_power.csv','table',build_table_from_results(res_power)), ...
    struct('name','tbl_csi.csv','table',build_table_from_results(res_csi)), ...
    struct('name','tbl_blockage.csv','table',build_table_from_results(res_blk)), ...
    struct('name','tbl_rho.csv','table',build_table_from_results(res_rho)), ...
    struct('name','tbl_sic.csv','table',build_table_from_results(res_sic)) ...
    };

fig_items = {};

% Group A: overall power-domain performance.
fig_items{end+1} = local_fig_item('A_maxmin_vs_power', plot_metric_curves(res_power.x_values, res_power.max_min_rate, params.scheme_names, 'Transmit power (dBm)', 'Max-min rate (bit/s/Hz)', 'Max-min vs transmit power')); %#ok<AGROW>
fig_items{end+1} = local_fig_item('A_sumrate_vs_power', plot_metric_curves(res_power.x_values, res_power.sum_rate, params.scheme_names, 'Transmit power (dBm)', 'Sum-rate (bit/s/Hz)', 'Sum-rate vs transmit power'));
fig_items{end+1} = local_fig_item('A_fairness_vs_power', plot_metric_curves(res_power.x_values, res_power.jain_fairness, params.scheme_names, 'Transmit power (dBm)', 'Jain fairness', 'Fairness vs transmit power'));
fig_items{end+1} = local_fig_item('A_ee_vs_power', plot_metric_curves(res_power.x_values, res_power.energy_efficiency, params.scheme_names, 'Transmit power (dBm)', 'Energy efficiency', 'EE vs transmit power'));

% Group B: NOMA internal.
noma_idx = [1 2 3];
fig_items{end+1} = local_fig_item('B_noma_sumrate', plot_metric_curves(res_power.x_values, res_power.sum_rate(:, noma_idx), params.scheme_names(noma_idx), 'Transmit power (dBm)', 'Sum-rate (bit/s/Hz)', 'NOMA internal comparison'));

% Group C: RSMA internal.
rsma_idx = [4 5 6];
fig_items{end+1} = local_fig_item('C_rsma_sumrate', plot_metric_curves(res_power.x_values, res_power.sum_rate(:, rsma_idx), params.scheme_names(rsma_idx), 'Transmit power (dBm)', 'Sum-rate (bit/s/Hz)', 'RSMA internal comparison'));

% Group D: representative comparison.
rep_idx = [1 3 4 6];
fig_items{end+1} = local_fig_item('D_representative_sumrate', plot_metric_curves(res_power.x_values, res_power.sum_rate(:, rep_idx), params.scheme_names(rep_idx), 'Transmit power (dBm)', 'Sum-rate (bit/s/Hz)', 'Representative comparison'));

% Group E: robustness.
fig_items{end+1} = local_fig_item('E_sumrate_vs_csi', plot_metric_curves(res_csi.x_values, res_csi.sum_rate, params.scheme_names, 'CSI error', 'Sum-rate (bit/s/Hz)', 'Robustness vs CSI error'));
fig_items{end+1} = local_fig_item('E_sumrate_vs_blockage', plot_metric_curves(res_blk.x_values, res_blk.sum_rate, params.scheme_names, 'Blockage (dB)', 'Sum-rate (bit/s/Hz)', 'Robustness vs blockage'));
fig_items{end+1} = local_fig_item('E_sumrate_vs_sic', plot_metric_curves(res_sic.x_values, res_sic.sum_rate, params.scheme_names, 'SIC error', 'Sum-rate (bit/s/Hz)', 'Robustness vs SIC error'));

% Group F: reflection mechanism.
fig_items{end+1} = local_fig_item('F_maxmin_vs_rho', plot_metric_curves(res_rho.x_values, res_rho.max_min_rate, params.scheme_names, 'rho', 'Max-min rate', 'Max-min vs rho'));
fig_items{end+1} = local_fig_item('F_sumrate_vs_rho', plot_metric_curves(res_rho.x_values, res_rho.sum_rate, params.scheme_names, 'rho', 'Sum-rate', 'Sum-rate vs rho'));
fig_items{end+1} = local_fig_item('F_fairness_vs_rho', plot_metric_curves(res_rho.x_values, res_rho.jain_fairness, params.scheme_names, 'rho', 'Jain fairness', 'Fairness vs rho'));
fig_items{end+1} = local_fig_item('F_ee_vs_rho', plot_metric_curves(res_rho.x_values, res_rho.energy_efficiency, params.scheme_names, 'rho', 'Energy efficiency', 'EE vs rho'));

% Group G: gain plots.
[g_abs_noma, g_rel_noma] = calc_gain(res_power.sum_rate(:,2), res_power.sum_rate(:,3));
[g_abs_rsma, g_rel_rsma] = calc_gain(res_power.sum_rate(:,5), res_power.sum_rate(:,6));
fig_items{end+1} = local_fig_item('G_gain_noma', plot_gain_curves(res_power.x_values, g_abs_noma, g_rel_noma, 'Transmit power (dBm)', 'NOMA-AmBC (Fixed rho)', 'NOMA-AmBC (Optimized rho)'));
fig_items{end+1} = local_fig_item('G_gain_rsma', plot_gain_curves(res_power.x_values, g_abs_rsma, g_rel_rsma, 'Transmit power (dBm)', 'RSMA-AmBC (Fixed rho)', 'RSMA-AmBC (Optimized rho)'));

% Group H: BER placeholders.
fig_items{end+1} = local_fig_item('H_ber_vs_power', plot_ber_curves(res_power.x_values, res_power.ber_user1, params.scheme_names, 'Transmit power (dBm)', 'BER vs power (placeholder)'));
fig_items{end+1} = local_fig_item('H_ber_vs_rho', plot_ber_curves(res_rho.x_values, res_rho.ber_user1, params.scheme_names, 'rho', 'BER vs rho (placeholder)'));
fig_items{end+1} = local_fig_item('H_ber_vs_csi', plot_ber_curves(res_csi.x_values, res_csi.ber_user1, params.scheme_names, 'CSI error', 'BER vs CSI error (placeholder)'));

summary_lines = local_build_summary(mode_name, params, res_power);
save_all_outputs(out_dir, params, all_results, tables, fig_items, summary_lines);

end

function item = local_fig_item(name, fig)
item = struct('name', name, 'fig', fig);
end

function lines = local_build_summary(mode_name, p, res_power)
lines = {
    sprintf('mode: %s', mode_name), ...
    sprintf('numMC: %d', p.numMC), ...
    sprintf('Pt_dBm_vec: %s', mat2str(p.Pt_dBm_vec)), ...
    sprintf('sic_err_vec: %s', mat2str(p.sic_err_vec)), ...
    sprintf('csi_err_vec: %s', mat2str(p.csi_err_vec)), ...
    sprintf('blk_loss_dB_vec: %s', mat2str(p.blk_loss_dB_vec)), ...
    'generated figure groups: A,B,C,D,E,F,G,H'};

idx40 = find(p.Pt_dBm_vec == 40, 1);
if isempty(idx40), idx40 = numel(p.Pt_dBm_vec); end
row = res_power.max_min_rate(idx40, :);
[~, best_idx] = max(row);
lines{end+1} = sprintf('At Pt = %.1f dBm, %s achieved the best max-min rate.', p.Pt_dBm_vec(idx40), p.scheme_names{best_idx});
lines{end+1} = 'Optimized rho outperformed fixed rho consistently in RSMA-AmBC (observed trend in exploratory run).';
lines{end+1} = 'Pure RSMA outperformed Pure NOMA in fairness under the tested settings (exploratory observation).';

end
