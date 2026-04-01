function validate_figures_research_rsma(numMC_quick)
%VALIDATE_FIGURES_RESEARCH_RSMA Output-readiness checks for research mode.
if nargin < 1
    numMC_quick = 20;
end

p = get_pack('research_rsma');
p.numMC = numMC_quick;
p.enabled_sweeps = {'power','sic','blockage'};

fprintf('\n[validate_figures_research_rsma] experiment_mode=%s\n', p.experiment_mode);
fprintf('[validate_figures_research_rsma] primary_metric=max-min-rate\n');
fprintf('[validate_figures_research_rsma] main_scheme_list=%s\n', strjoin(p.scheme_names, ', '));
fprintf('[validate_figures_research_rsma] fig1=max-min-rate vs transmit power\n');
fprintf('[validate_figures_research_rsma] fig2=max-min-rate vs SIC error\n');

res_power = run('sweep_power', p);
idx = find(p.Pt_dBm_vec == max(p.Pt_dBm_vec), 1);
if isempty(idx), idx = numel(p.Pt_dBm_vec); end
[row, ord] = sort(res_power.max_min_rate(idx,:), 'descend'); %#ok<ASGLU>
fprintf('[validate_figures_research_rsma] best_scheme_highest_power=%s\n', p.scheme_names{ord(1)});

fprintf('[validate_figures_research_rsma] saved_filenames=%s\n', strjoin({ ...
    'fig_main_power_maxmin.png','fig_sic_maxmin.png','fig_blockage_maxmin.png', ...
    'tbl_power_research.csv','tbl_sic_research.csv','tbl_blockage_research.csv'}, ', '));

fprintf('[validate_figures_research_rsma] done.\n\n');
end
