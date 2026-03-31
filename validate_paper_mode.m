function validate_paper_mode(numMC_quick)
%VALIDATE_PAPER_MODE Lightweight sanity checks for paper_reproduction mode.
% Prints:
% - experiment_mode
% - scheme_names
% - max(xi_grid)
% - harvest_cfg.enable
% - ordering at 40 dBm (sum-rate)
% - SIC-trend check for NOMA-family sum-rate

if nargin < 1
    numMC_quick = 40;
end

p = get_pack('paper_reproduction');
p.numMC = numMC_quick;

fprintf('\n[validate_paper_mode] mode=%s\n', p.experiment_mode);
fprintf('[validate_paper_mode] schemes=%s\n', strjoin(p.scheme_names, ', '));
fprintf('[validate_paper_mode] max(xi_grid)=%.3f\n', max(p.xi_grid));
fprintf('[validate_paper_mode] harvest_cfg.enable=%d\n', p.harvest_cfg.enable);

res_power = run('sweep_power', p);
res_sic = run('sweep_sic', p);

idx40 = find(p.Pt_dBm_vec == 40, 1);
if isempty(idx40), idx40 = numel(p.Pt_dBm_vec); end
[vals, ord] = sort(res_power.sum_rate(idx40,:), 'descend');
ordered_names = p.scheme_names(ord);

fprintf('[validate_paper_mode] ordering@%.1fdBm (sum-rate):\n', p.Pt_dBm_vec(idx40));
for i = 1:numel(ordered_names)
    fprintf('  %d) %s : %.4f\n', i, ordered_names{i}, vals(i));
end

noma_family = {'Proposed NOMA-AmBC','Benchmark NOMA-AmBC (fixed rho)','Pure NOMA'};
for i = 1:numel(noma_family)
    idx = find(strcmp(p.scheme_names, noma_family{i}), 1);
    if isempty(idx), continue; end
    sr = res_sic.sum_rate(:, idx);
    dec_frac = mean(diff(sr) <= 0);
    fprintf('[validate_paper_mode] SIC trend %-32s decreasing-step-frac=%.2f\n', noma_family{i}, dec_frac);
end

fprintf('[validate_paper_mode] done.\n\n');
end
