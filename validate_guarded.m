% VALIDATE_GUARDED Compare unguarded vs guarded RSMA optimization behavior.
% Configuration A (unguarded): max_common_frac=1.0, min_private_frac=0.0
% Configuration B (guarded):   max_common_frac=0.8, min_private_frac=0.05

fprintf('\n[validate_guarded] Building debug parameter sets...\n');

pA = get_pack('debug');
pA.harvest_cfg.max_common_frac = 1.0;
pA.harvest_cfg.min_private_frac = 0.0;

pB = get_pack('debug');
pB.harvest_cfg.max_common_frac = 0.8;
pB.harvest_cfg.min_private_frac = 0.05;

fprintf('[validate_guarded] Run A (unguarded) sweeps...\n');
resA_power = run('sweep_power', pA);
resA_rho = run('sweep_rho', pA);

fprintf('[validate_guarded] Run B (guarded) sweeps...\n');
resB_power = run('sweep_power', pB);
resB_rho = run('sweep_rho', pB);

idxA = find(pA.Pt_dBm_vec == pA.Pt_dBm_default, 1);
if isempty(idxA), idxA = numel(pA.Pt_dBm_vec); end
idxB = find(pB.Pt_dBm_vec == pB.Pt_dBm_default, 1);
if isempty(idxB), idxB = numel(pB.Pt_dBm_vec); end

fprintf('\n=== Guarded vs Unguarded @ Pt=%.1f dBm ===\n', pA.Pt_dBm_vec(idxA));
print_scheme_block('A: unguarded', pA.scheme_names, resA_power, idxA);
print_scheme_block('B: guarded', pB.scheme_names, resB_power, idxB);

fprintf('\n=== Optimizer statistics (power sweep @ reference point) ===\n');
print_opt_stats('A: unguarded', resA_power, idxA);
print_opt_stats('B: guarded', resB_power, idxB);

fprintf('\n=== Rho sweep interpretation note ===\n');
fprintf('Optimized schemes in rho sweep are evaluated with best rho <= x (plus feasibility), not fixed rho=x.\n');

fprintf('\n[validate_guarded] Completed.\n');

function print_scheme_block(tag, names, res, idx)
fprintf('\n[%s]\n', tag);
for is = 1:numel(names)
    fprintf('%s | sum-rate=%.4f | max-min=%.4f | rho_used=%.3f\n', ...
        names{is}, res.sum_rate(idx,is), res.max_min_rate(idx,is), res.rho_used(idx,is));
end
end

function print_opt_stats(tag, res, idx)
fprintf('[%s]\n', tag);
if isfield(res, 'noma_opt_avg_rho')
    fprintf('NOMA-opt: avg_rho=%.3f | hit_feasible=%.3f | skip_infeasible=%.3f\n', ...
        res.noma_opt_avg_rho(idx), res.noma_opt_hit_feasible_frac(idx), res.noma_opt_skip_infeasible_frac(idx));
end
if isfield(res, 'rsma_opt_avg_zeta')
    fprintf(['RSMA-opt: avg_zeta=%.3f | hit_feasible=%.3f | skip_infeasible=%.3f | all_common=%.3f | ' ...
             'alpha=(%.3f,%.3f,%.3f) | mu=%.3f | P=(%.4g,%.4g,%.4g)\n'], ...
        res.rsma_opt_avg_zeta(idx), res.rsma_opt_hit_feasible_frac(idx), res.rsma_opt_skip_infeasible_frac(idx), res.rsma_opt_all_common_frac(idx), ...
        res.rsma_opt_alpha_c(idx), res.rsma_opt_alpha_1(idx), res.rsma_opt_alpha_2(idx), res.rsma_opt_mu(idx), ...
        res.rsma_opt_Pc(idx), res.rsma_opt_P1(idx), res.rsma_opt_P2(idx));
end
end
