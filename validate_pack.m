function validate_pack(mode, varargin)
%VALIDATE_PACK Unified validation pack entrypoint.
% Modes:
%   validate_pack('research_rsma', numMC_quick)
%   validate_pack('paper_reproduction', numMC_quick)
%   validate_pack('guarded')

switch lower(mode)
    case {'research','research_rsma'}
        if isempty(varargin), n = 30; else, n = varargin{1}; end
        local_validate_research_rsma(n);
    case {'paper','paper_reproduction'}
        if isempty(varargin), n = 40; else, n = varargin{1}; end
        local_validate_paper_mode(n);
    case {'guarded','validate_guarded'}
        local_validate_guarded();
    otherwise
        error('Unknown validate_pack mode: %s', mode);
end
end

function local_validate_research_rsma(numMC_quick)
p = get_pack('research_rsma');
p.numMC = numMC_quick;
p.enabled_sweeps = {'power','sic','blockage'};
fprintf('\n[validate_research_rsma] experiment_mode=%s\n', p.experiment_mode);
fprintf('[validate_research_rsma] primary_metric=max-min-rate\n');
fprintf('[validate_research_rsma] scheme_names=%s\n', strjoin(p.scheme_names, ', '));
expected = {'Pure SDMA','SDMA-AmBC','Pure NOMA','NOMA-AmBC','Pure RSMA','RSMA-AmBC'};
has_six = all(ismember(expected, p.scheme_names));
fprintf('[validate_research_rsma] six_target_families_present=%d\n', has_six);
pp = get_pack('paper_reproduction');
paper_untouched = strcmp(pp.experiment_mode, 'paper_reproduction') && max(pp.xi_grid) <= 0.5 && (~pp.harvest_cfg.enable);
fprintf('[validate_research_rsma] paper_reproduction_untouched=%d\n', paper_untouched);
fprintf('[validate_research_rsma] fig1=max-min-rate vs transmit power\n');
fprintf('[validate_research_rsma] fig2=max-min-rate vs SIC error\n');
res_power = run('sweep_power', p);
idx = find(p.Pt_dBm_vec == max(p.Pt_dBm_vec), 1); if isempty(idx), idx = numel(p.Pt_dBm_vec); end
[vals, ord] = sort(res_power.max_min_rate(idx,:), 'descend'); ord_names = p.scheme_names(ord);
fprintf('[validate_research_rsma] ordering@%.1fdBm by max-min-rate:\n', p.Pt_dBm_vec(idx));
for i = 1:numel(ord_names), fprintf('  %d) %s : %.4f\n', i, ord_names{i}, vals(i)); end
fprintf('[validate_research_rsma] best_scheme_highest_power=%s\n', ord_names{1});
fprintf('[validate_research_rsma] main_figure_metric=max-min-rate (fig_main_power_maxmin)\n');
fprintf('[validate_research_rsma] saved_filenames=%s\n', strjoin({'fig_main_power_maxmin.png','fig_sic_maxmin.png','fig_blockage_maxmin.png','tbl_power_research.csv','tbl_sic_research.csv','tbl_blockage_research.csv'}, ', '));
fprintf('[validate_research_rsma] oma_family_sic_note=SDMA-family uses OMA formulas without SIC term; SIC sweeps are expected to be SIC-independent in-model.\n');
fprintf('[validate_research_rsma] done.\n\n');
end

function local_validate_paper_mode(numMC_quick)
p = get_pack('paper_reproduction');
p.numMC = numMC_quick;
fprintf('\n[validate_paper_mode] mode=%s\n', p.experiment_mode);
fprintf('[validate_paper_mode] schemes=%s\n', strjoin(p.scheme_names, ', '));
fprintf('[validate_paper_mode] max(xi_grid)=%.3f\n', max(p.xi_grid));
fprintf('[validate_paper_mode] harvest_cfg.enable=%d\n', p.harvest_cfg.enable);
pcfg = p.plot_cfg;
only_paper_sweeps = isequal(sort(p.enabled_sweeps), sort({'power','sic'}));
only_paper_plots = local_get_or(pcfg,'plot_power_sum',false) && local_get_or(pcfg,'plot_sic',false) && ...
    ~local_get_or(pcfg,'plot_power_mm',false) && ~local_get_or(pcfg,'plot_blockage_mm',false) && ...
    ~local_get_or(pcfg,'plot_csi',false) && ~local_get_or(pcfg,'plot_rho',false) && ~local_get_or(pcfg,'plot_rsma_diag',false);
fprintf('[validate_paper_mode] paper_style_only=%d (sweeps=%d, plots=%d)\n', only_paper_sweeps && only_paper_plots, only_paper_sweeps, only_paper_plots);
fprintf('[validate_paper_mode] oma_baseline_type=true OMA-AmBC\n');
res_power = run('sweep_power', p); res_sic = run('sweep_sic', p);
idx40 = find(p.Pt_dBm_vec == 40, 1); if isempty(idx40), idx40 = numel(p.Pt_dBm_vec); end
[vals, ord] = sort(res_power.sum_rate(idx40,:), 'descend'); ordered_names = p.scheme_names(ord);
fprintf('[validate_paper_mode] ordering@%.1fdBm (sum-rate):\n', p.Pt_dBm_vec(idx40));
for i = 1:numel(ordered_names), fprintf('  %d) %s : %.4f\n', i, ordered_names{i}, vals(i)); end
noma_family = {'Proposed NOMA-AmBC','Benchmark NOMA-AmBC (fixed rho)','Pure NOMA'};
for i = 1:numel(noma_family)
    idx = find(strcmp(p.scheme_names, noma_family{i}), 1); if isempty(idx), continue; end
    sr = res_sic.sum_rate(:, idx); dec_frac = mean(diff(sr) <= 0);
    fprintf('[validate_paper_mode] SIC trend %-32s decreasing-step-frac=%.2f\n', noma_family{i}, dec_frac);
end
fprintf('[validate_paper_mode] done.\n\n');
end

function local_validate_guarded()
fprintf('\n[validate_guarded] Building debug parameter sets...\n');
pA = get_pack('debug'); pA.harvest_cfg.max_common_frac = 1.0; pA.harvest_cfg.min_private_frac = 0.0;
pB = get_pack('debug'); pB.harvest_cfg.max_common_frac = 0.8; pB.harvest_cfg.min_private_frac = 0.05;
fprintf('[validate_guarded] Run A (unguarded) sweeps...\n');
resA_power = run('sweep_power', pA);
fprintf('[validate_guarded] Run B (guarded) sweeps...\n');
resB_power = run('sweep_power', pB);
idxA = find(pA.Pt_dBm_vec == pA.Pt_dBm_default, 1); if isempty(idxA), idxA = numel(pA.Pt_dBm_vec); end
idxB = find(pB.Pt_dBm_vec == pB.Pt_dBm_default, 1); if isempty(idxB), idxB = numel(pB.Pt_dBm_vec); end
fprintf('\n=== Guarded vs Unguarded @ Pt=%.1f dBm ===\n', pA.Pt_dBm_vec(idxA));
for is = 1:numel(pA.scheme_names)
    fprintf('[A] %s | sum-rate=%.4f | max-min=%.4f\n', pA.scheme_names{is}, resA_power.sum_rate(idxA,is), resA_power.max_min_rate(idxA,is));
    fprintf('[B] %s | sum-rate=%.4f | max-min=%.4f\n', pB.scheme_names{is}, resB_power.sum_rate(idxB,is), resB_power.max_min_rate(idxB,is));
end
fprintf('[validate_guarded] Completed.\n');
end

function v = local_get_or(s, k, d)
if isfield(s, k), v = s.(k); else, v = d; end
end
