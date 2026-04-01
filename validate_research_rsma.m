function validate_research_rsma(numMC_quick)
%VALIDATE_RESEARCH_RSMA Unified research-mode validation/output-readiness check.
if nargin < 1
    numMC_quick = 30;
end

p = get_pack('research_rsma');
p.numMC = numMC_quick;
p.enabled_sweeps = {'power','sic','blockage'};

fprintf('\n[validate_research_rsma] experiment_mode=%s\n', p.experiment_mode);
fprintf('[validate_research_rsma] primary_metric=max-min-rate\n');
fprintf('[validate_research_rsma] scheme_names=%s\n', strjoin(p.scheme_names, ', '));

expected = {'Pure OMA','OMA-AmBC','Pure NOMA','NOMA-AmBC','Pure RSMA','RSMA-AmBC'};
has_six = all(ismember(expected, p.scheme_names));
fprintf('[validate_research_rsma] six_target_families_present=%d\n', has_six);

pp = get_pack('paper_reproduction');
paper_untouched = strcmp(pp.experiment_mode, 'paper_reproduction') && max(pp.xi_grid) <= 0.5 && (~pp.harvest_cfg.enable);
fprintf('[validate_research_rsma] paper_reproduction_untouched=%d\n', paper_untouched);

fprintf('[validate_research_rsma] fig1=max-min-rate vs transmit power\n');
fprintf('[validate_research_rsma] fig2=max-min-rate vs SIC error\n');

res_power = run('sweep_power', p);
idx = find(p.Pt_dBm_vec == max(p.Pt_dBm_vec), 1);
if isempty(idx), idx = numel(p.Pt_dBm_vec); end
[vals, ord] = sort(res_power.max_min_rate(idx,:), 'descend');
ord_names = p.scheme_names(ord);

fprintf('[validate_research_rsma] ordering@%.1fdBm by max-min-rate:\n', p.Pt_dBm_vec(idx));
for i = 1:numel(ord_names)
    fprintf('  %d) %s : %.4f\n', i, ord_names{i}, vals(i));
end
fprintf('[validate_research_rsma] best_scheme_highest_power=%s\n', ord_names{1});

fprintf('[validate_research_rsma] main_figure_metric=max-min-rate (fig_main_power_maxmin)\n');
fprintf('[validate_research_rsma] saved_filenames=%s\n', strjoin({ ...
    'fig_main_power_maxmin.png','fig_sic_maxmin.png','fig_blockage_maxmin.png', ...
    'tbl_power_research.csv','tbl_sic_research.csv','tbl_blockage_research.csv'}, ', '));
fprintf('[validate_research_rsma] oma_family_sic_note=OMA-family uses OMA formulas without SIC term; SIC sweeps are expected to be SIC-independent in-model.\n');

fprintf('[validate_research_rsma] done.\n\n');
end
