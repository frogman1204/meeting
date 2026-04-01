function validate_research_rsma(numMC_quick)
%VALIDATE_RESEARCH_RSMA Lightweight validation for research_rsma mode.
if nargin < 1
    numMC_quick = 30;
end

p = get_pack('research_rsma');
p.numMC = numMC_quick;
p.enabled_sweeps = {'power'};

fprintf('\n[validate_research_rsma] experiment_mode=%s\n', p.experiment_mode);
fprintf('[validate_research_rsma] primary_metric=max-min-rate\n');
fprintf('[validate_research_rsma] scheme_names=%s\n', strjoin(p.scheme_names, ', '));

expected = {'Pure NOMA','NOMA-AmBC','Pure RSMA','RSMA-AmBC'};
has_four = all(ismember(expected, p.scheme_names));
fprintf('[validate_research_rsma] four_target_families_present=%d\n', has_four);

paper_untouched = true;
pp = get_pack('paper_reproduction');
paper_untouched = paper_untouched && strcmp(pp.experiment_mode, 'paper_reproduction');
paper_untouched = paper_untouched && max(pp.xi_grid) <= 0.5 && (~pp.harvest_cfg.enable);
fprintf('[validate_research_rsma] paper_reproduction_untouched=%d\n', paper_untouched);

res_power = run('sweep_power', p);
idx = find(p.Pt_dBm_vec == max(p.Pt_dBm_vec), 1);
if isempty(idx), idx = numel(p.Pt_dBm_vec); end
[vals, ord] = sort(res_power.max_min_rate(idx,:), 'descend');
ord_names = p.scheme_names(ord);

fprintf('[validate_research_rsma] ordering@%.1fdBm by max-min-rate:\n', p.Pt_dBm_vec(idx));
for i = 1:numel(ord_names)
    fprintf('  %d) %s : %.4f\n', i, ord_names{i}, vals(i));
end

fprintf('[validate_research_rsma] main_figure_metric=max-min-rate (power_maxmin)\n');
fprintf('[validate_research_rsma] done.\n\n');
end
