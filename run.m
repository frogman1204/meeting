function out = run(mode, varargin)
%RUN Grouped run_* logic in one file.
% Modes:
%   'medium'/'full' : full pipeline run with preset params
%   'core'          : internal full pipeline with params
%   'sweep_power'/'sweep_csi'/'sweep_blockage'/'sweep_rho'/'sweep_sic'/'sweep_tags'

switch lower(mode)
    case 'medium'
        params = get_pack('medium');
        out = run('core', params, 'medium');
    case 'full'
        params = get_pack('full');
        out = run('core', params, 'full');
    case 'debug'
        params = get_pack('debug');
        out = run('core', params, 'debug');
    case 'paper_reproduction'
        params = get_pack('paper_reproduction');
        out = run('core', params, 'paper_reproduction');
    case 'research_rsma'
        params = get_pack('research_rsma');
        out = run('core', params, 'research_rsma');
    case 'core'
        out = run_core(varargin{1}, varargin{2});
    case 'sweep_power'
        out = run_sweep_local('power', varargin{1});
    case 'sweep_csi'
        out = run_sweep_local('csi', varargin{1});
    case 'sweep_blockage'
        out = run_sweep_local('blockage', varargin{1});
    case 'sweep_rho'
        out = run_sweep_local('rho', varargin{1});
    case 'sweep_sic'
        out = run_sweep_local('sic', varargin{1});
    case 'sweep_tags'
        out = run_sweep_tags_local(varargin{1});
    otherwise
        error('Unknown run mode: %s', mode);
end

end

function out_dir = run_core(params, mode_name)
rng(params.rng_seed);
ts = datestr(now, 'yyyymmdd_HHMMSS');
out_dir = fullfile('out', sprintf('%s_run_%s', mode_name, ts));
enabled = local_get_or(params, 'enabled_sweeps', {'power','csi','blockage','rho','sic','tags'});

fprintf('\n[run] mode=%s | numMC=%d | start=%s\n', mode_name, params.numMC, ts);

res_power = run_or_empty('power', enabled, params);
res_csi = run_or_empty('csi', enabled, params);
res_blk = run_or_empty('blockage', enabled, params);
res_rho = run_or_empty('rho', enabled, params);
res_sic = run_or_empty('sic', enabled, params);
res_tags = run_or_empty('tags', enabled, params);

all_results = struct('power',res_power,'csi',res_csi,'blockage',res_blk,'rho',res_rho,'sic',res_sic,'tags',res_tags);
exp_mode0 = local_get_or(params,'experiment_mode','research_rsma');
if strcmpi(exp_mode0,'paper_reproduction')
    tables = { ...
     struct('name','tbl_power_paper.csv','table',calc_pack('build_table_from_results',res_power)), ...
     struct('name','tbl_sic_paper.csv','table',calc_pack('build_table_from_results',res_sic))};
else
    tables = { ...
     struct('name','tbl_power_research.csv','table',calc_pack('build_table_from_results',res_power)), ...
     struct('name','tbl_sic_research.csv','table',calc_pack('build_table_from_results',res_sic)), ...
     struct('name','tbl_blockage_research.csv','table',calc_pack('build_table_from_results',res_blk))};
end

figs = {};
pcfg = local_get_or(params, 'plot_cfg', struct());
exp_mode = local_get_or(params,'experiment_mode','research_rsma');
if strcmpi(exp_mode, 'paper_reproduction')
    if local_get_or(pcfg, 'plot_power_sum', true)
        figs{end+1}=item('power_sumrate',plot_pack('metric',res_power.x_values,res_power.sum_rate,params.scheme_names,'Transmit power (dBm)','Sum-rate (bit/s/Hz)','Power vs sum-rate'));
    end
    if local_get_or(pcfg, 'plot_sic', true)
        figs{end+1}=item('sic_sumrate',plot_pack('metric',res_sic.x_values,res_sic.sum_rate,params.scheme_names,'SIC error','Sum-rate (bit/s/Hz)','SIC vs sum-rate'));
    end
else
    if local_get_or(pcfg, 'plot_power_mm', true)
        figs{end+1}=item('fig_main_power_maxmin',plot_pack('metric_main6',res_power.x_values,res_power.max_min_rate,params.scheme_names,'Transmit power (dBm)','Max-min rate (bit/s/Hz)','Figure 1: Max-min rate vs transmit power'));
    end
    if local_get_or(pcfg, 'plot_power_sum', true)
        figs{end+1}=item('power_sumrate',plot_pack('metric',res_power.x_values,res_power.sum_rate,params.scheme_names,'Transmit power (dBm)','Sum-rate (bit/s/Hz)','Power vs sum-rate'));
    end
    if local_get_or(pcfg, 'plot_blockage_mm', true)
        figs{end+1}=item('fig_blockage_maxmin',plot_pack('metric',res_blk.x_values,res_blk.max_min_rate,params.scheme_names,'Blockage (dB)','Max-min rate','Figure 3 (optional): Max-min rate vs blockage'));
    end
    if local_get_or(pcfg, 'plot_csi', true)
        figs{end+1}=item('csi_maxmin',plot_pack('metric',res_csi.x_values,res_csi.max_min_rate,params.scheme_names,'CSI error','Max-min rate','CSI sweep'));
    end
    if local_get_or(pcfg, 'plot_rho', true)
        figs{end+1}=item('rho_maxmin',plot_pack('metric',res_rho.x_values,res_rho.max_min_rate,params.scheme_names,'rho','Max-min rate','rho sweep'));
    end
    if local_get_or(pcfg, 'plot_sic', true)
        figs{end+1}=item('fig_sic_maxmin',plot_pack('metric_main6',res_sic.x_values,res_sic.max_min_rate,params.scheme_names,'SIC error','Max-min rate (bit/s/Hz)','Figure 2: Max-min rate vs SIC error'));
    end
    if local_get_or(pcfg, 'plot_rsma_diag', true) && isfield(res_power,'rsma_opt_all_common_frac')
        diag_mat = repmat(res_power.rsma_opt_all_common_frac, 1, 1);
        figs{end+1}=item('rsma_allcommon_diag',plot_pack('metric',res_power.x_values,diag_mat,{'RSMA-opt all-common fraction'},'Transmit power (dBm)','Fraction','RSMA-opt all-common diagnostic'));
    end
end

summary = summary_local(mode_name, params, res_power);
print_scheme_metrics_local(params, res_power);
save_pack(out_dir, params, all_results, tables, figs, summary);
end

function res = run_or_empty(kind, enabled, params)
if any(strcmpi(enabled, kind))
    sw = tic;
    fprintf('[run] sweep %s: start\n', kind);
    if strcmpi(kind, 'tags')
        res = run_sweep_tags_local(params);
    else
        res = run_sweep_local(kind, params);
    end
    fprintf('[run] sweep %s: done (%.2fs)\n', kind, toc(sw));
else
    fprintf('[run] sweep %s: skipped by config\n', kind);
    res = local_empty_result(kind, params.scheme_names);
end
end

function res = run_sweep_local(kind, p)
switch lower(kind)
 case 'power', xvec=p.Pt_dBm_vec; xlab='Transmit power (dBm)';
 case 'csi', xvec=p.csi_err_vec; xlab='CSI error level';
 case 'blockage', xvec=p.blk_loss_dB_vec; xlab='Blockage severity (dB)';
 case 'rho', xvec=p.rho_plot_vec; xlab='Reflection coefficient rho';
 case 'sic', xvec=p.sic_err_vec; xlab='SIC imperfection';
 otherwise, error('Unknown sweep kind');
end
ns=numel(p.scheme_names); nx=numel(xvec); fns={'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for k=1:numel(fns), res.(fns{k})=nan(nx,ns); end
fprintf('[sweep:%s] x_count=%d | numMC=%d\n', kind, nx, p.numMC);
if strcmp(kind,'rho')
    fprintf('[sweep:rho] note: optimized schemes use best rho subject to rho <= x and feasibility.\n');
end
tick_mc = max(1, floor(p.numMC/10));
for ix=1:nx
    t_ix = tic;
    Pt=10^((p.Pt_dBm_default-30)/10); sic=p.sic_err_vec(1); csi=p.csi_err_vec(1); blk=p.blk_loss_dB_vec(1); rho_fixed=p.rho_fixed; rho_grid=p.rho_grid;
    if strcmp(kind,'power'), Pt=10^((xvec(ix)-30)/10); end
    if strcmp(kind,'csi'), csi=xvec(ix); end
    if strcmp(kind,'blockage'), blk=xvec(ix); end
    if strcmp(kind,'sic'), sic=xvec(ix); end
    if strcmp(kind,'rho'), rho_fixed=xvec(ix); rho_grid=p.rho_grid(p.rho_grid<=xvec(ix)); if isempty(rho_grid), rho_grid=xvec(ix); end, end
    fprintf('[sweep:%s] x %d/%d | value=%.4g\n', kind, ix, nx, xvec(ix));
    tmp=zeros(p.numMC,ns,12);
    noma_rho_sel = nan(p.numMC,1); noma_rho_max = nan(p.numMC,1); noma_hit = nan(p.numMC,1); noma_skip = nan(p.numMC,1);
    rsma_zeta_sel = nan(p.numMC,1); rsma_zeta_max = nan(p.numMC,1); rsma_hit = nan(p.numMC,1); rsma_skip = nan(p.numMC,1);
    rsma_ac = nan(p.numMC,1); rsma_a1 = nan(p.numMC,1); rsma_a2 = nan(p.numMC,1); rsma_mu = nan(p.numMC,1);
    rsma_pc = nan(p.numMC,1); rsma_p1 = nan(p.numMC,1); rsma_p2 = nan(p.numMC,1); rsma_all_common = nan(p.numMC,1);
    xi_used = nan(p.numMC,ns); mu_used = nan(p.numMC,ns);
    pc_used = nan(p.numMC,ns); p1_used = nan(p.numMC,ns); p2_used = nan(p.numMC,ns);
    all_common_used = nan(p.numMC,ns);
    for imc=1:p.numMC
        if imc == 1 || imc == p.numMC || mod(imc, tick_mc) == 0
            fprintf('  [sweep:%s x:%d/%d] MC %d/%d\n', kind, ix, nx, imc, p.numMC);
        end
        ch=apply_pack('generate_channels'); ch=apply_pack('apply_csi_error',ch,csi); ch=apply_pack('apply_blockage_effect',ch,blk);
        sols = cell(1, ns);
        for is=1:ns
            key = p.scheme_keys{is};
            if any(strcmp(key, {'pure_oma','pure_noma','pure_rsma'}))
                rho_arg_local = 0;
            elseif any(strcmp(key, {'oma_ambc'}))
                rho_arg_local = rho_fixed;
            else
                rho_arg_local = rho_grid;
            end
            sols{is} = solve_pack(key,ch,Pt,sic,p.sigma2,rho_arg_local,p.rate_threshold,p.harvest_cfg,p.xi_grid,local_get_or(p,'experiment_mode','research_rsma'));
        end
        nopt = local_get_scheme_sol(sols, p, 'noma_opt');
        ropt = local_get_scheme_sol(sols, p, 'rsma_opt');
        if ~isempty(nopt) && isfield(nopt,'rho_opt'), noma_rho_sel(imc)=nopt.rho_opt; end
        if ~isempty(nopt) && isfield(nopt,'rho_feasible_max'), noma_rho_max(imc)=nopt.rho_feasible_max; end
        if ~isempty(nopt) && isfield(nopt,'hit_feasible_bound'), noma_hit(imc)=nopt.hit_feasible_bound; end
        if ~isempty(nopt) && isfield(nopt,'infeasible_skip_frac'), noma_skip(imc)=nopt.infeasible_skip_frac; end
        if ~isempty(ropt) && isfield(ropt,'rho_opt'), rsma_zeta_sel(imc)=ropt.rho_opt; end
        if ~isempty(ropt) && isfield(ropt,'zeta_feasible_max'), rsma_zeta_max(imc)=ropt.zeta_feasible_max; end
        if ~isempty(ropt) && isfield(ropt,'hit_feasible_bound'), rsma_hit(imc)=ropt.hit_feasible_bound; end
        if ~isempty(ropt) && isfield(ropt,'infeasible_skip_frac'), rsma_skip(imc)=ropt.infeasible_skip_frac; end
        if ~isempty(ropt) && isfield(ropt,'alpha_c'), rsma_ac(imc)=ropt.alpha_c; end
        if ~isempty(ropt) && isfield(ropt,'alpha_1'), rsma_a1(imc)=ropt.alpha_1; end
        if ~isempty(ropt) && isfield(ropt,'alpha_2'), rsma_a2(imc)=ropt.alpha_2; end
        if ~isempty(ropt) && isfield(ropt,'mu'), rsma_mu(imc)=ropt.mu; end
        if ~isempty(ropt) && isfield(ropt,'Pc'), rsma_pc(imc)=ropt.Pc; end
        if ~isempty(ropt) && isfield(ropt,'P1'), rsma_p1(imc)=ropt.P1; end
        if ~isempty(ropt) && isfield(ropt,'P2'), rsma_p2(imc)=ropt.P2; end
        if ~isempty(ropt) && isfield(ropt,'is_all_common'), rsma_all_common(imc)=ropt.is_all_common; end
        for is=1:ns
            if isfield(sols{is},'xi_used')
                xi_used(imc,is)=sols{is}.xi_used;
            end
            if isfield(sols{is},'mu')
                mu_used(imc,is)=sols{is}.mu;
            end
            if isfield(sols{is},'Pc')
                pc_used(imc,is)=sols{is}.Pc;
                p1_used(imc,is)=sols{is}.P1;
                p2_used(imc,is)=sols{is}.P2;
            end
            if isfield(sols{is},'is_all_common')
                all_common_used(imc,is)=sols{is}.is_all_common;
            end
        end
        for is=1:ns
            s=sols{is}; tmp(imc,is,:)=[s.R1 s.R2 s.sum_rate s.max_min_rate s.jain_fairness s.energy_efficiency s.rho_used s.rho_opt s.ber_tag s.ber_user1 s.ber_user2 s.outage_flag];
        end
    end
    avg=squeeze(mean(tmp,1));
    res.R1(ix,:)=avg(:,1)'; res.R2(ix,:)=avg(:,2)'; res.sum_rate(ix,:)=avg(:,3)'; res.max_min_rate(ix,:)=avg(:,4)';
    res.jain_fairness(ix,:)=avg(:,5)'; res.energy_efficiency(ix,:)=avg(:,6)'; res.rho_used(ix,:)=avg(:,7)'; res.rho_opt(ix,:)=avg(:,8)';
    res.ber_tag(ix,:)=avg(:,9)'; res.ber_user1(ix,:)=avg(:,10)'; res.ber_user2(ix,:)=avg(:,11)'; res.outage_flag(ix,:)=avg(:,12)';
    res.noma_opt_avg_rho(ix,1)=mean(noma_rho_sel,'omitnan');
    res.noma_opt_hit_feasible_frac(ix,1)=mean(noma_hit,'omitnan');
    res.noma_opt_skip_infeasible_frac(ix,1)=mean(noma_skip,'omitnan');
    res.rsma_opt_avg_zeta(ix,1)=mean(rsma_zeta_sel,'omitnan');
    res.rsma_opt_hit_feasible_frac(ix,1)=mean(rsma_hit,'omitnan');
    res.rsma_opt_skip_infeasible_frac(ix,1)=mean(rsma_skip,'omitnan');
    res.rsma_opt_all_common_frac(ix,1)=mean(rsma_all_common,'omitnan');
    res.rsma_opt_alpha_c(ix,1)=mean(rsma_ac,'omitnan');
    res.rsma_opt_alpha_1(ix,1)=mean(rsma_a1,'omitnan');
    res.rsma_opt_alpha_2(ix,1)=mean(rsma_a2,'omitnan');
    res.rsma_opt_mu(ix,1)=mean(rsma_mu,'omitnan');
    res.rsma_opt_Pc(ix,1)=mean(rsma_pc,'omitnan');
    res.rsma_opt_P1(ix,1)=mean(rsma_p1,'omitnan');
    res.rsma_opt_P2(ix,1)=mean(rsma_p2,'omitnan');
    res.scheme_avg_xi(ix,:)=mean(xi_used,1,'omitnan');
    res.scheme_avg_mu(ix,:)=mean(mu_used,1,'omitnan');
    res.scheme_avg_Pc(ix,:)=mean(pc_used,1,'omitnan');
    res.scheme_avg_P1(ix,:)=mean(p1_used,1,'omitnan');
    res.scheme_avg_P2(ix,:)=mean(p2_used,1,'omitnan');
    res.scheme_all_common_frac(ix,:)=mean(all_common_used,1,'omitnan');
    fprintf('[sweep:%s] x %d/%d done | elapsed=%.2fs\n', kind, ix, nx, toc(t_ix));
end
res.x_values=xvec; res.scheme_names=p.scheme_names; res.sweep_name=kind; res.x_label=xlab;
end

function res = run_sweep_tags_local(p)
nx=numel(p.tag_count_vec); ns=numel(p.scheme_names);
res.x_values=p.tag_count_vec; res.scheme_names=p.scheme_names; res.sweep_name='tags'; res.x_label='Tag count';
fns={'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for k=1:numel(fns), res.(fns{k})=nan(nx,ns); end
fprintf('[sweep:tags] WARNING: tags sweep is TODO/placeholder and currently returns NaN metrics.\n');
end

function lines = summary_local(mode_name,p,res_power)
pcfg = local_get_or(p, 'plot_cfg', struct());
lines={sprintf('mode: %s',mode_name),sprintf('numMC: %d',p.numMC),sprintf('Pt_dBm_vec: %s',mat2str(p.Pt_dBm_vec)),sprintf('sic_err_vec: %s',mat2str(p.sic_err_vec)),sprintf('csi_err_vec: %s',mat2str(p.csi_err_vec)),sprintf('blk_loss_dB_vec: %s',mat2str(p.blk_loss_dB_vec)),sprintf('plot switches: %s', jsonencode(pcfg))};
idx40=find(p.Pt_dBm_vec==40,1); if isempty(idx40), idx40=numel(p.Pt_dBm_vec); end
exp_mode = local_get_or(p,'experiment_mode','research_rsma');
if strcmpi(exp_mode,'paper_reproduction')
    row=res_power.sum_rate(idx40,:); [~,best_idx]=max(row);
    lines{end+1}=sprintf('At Pt = %.1f dBm, best sum-rate scheme: %s.',p.Pt_dBm_vec(idx40),p.scheme_names{best_idx});
else
    row=res_power.max_min_rate(idx40,:); [~,best_idx]=max(row);
    lines{end+1}=sprintf('At Pt = %.1f dBm, best max-min scheme: %s.',p.Pt_dBm_vec(idx40),p.scheme_names{best_idx});
    [vals, ord] = sort(row, 'descend');
    lines{end+1}=sprintf('Ordering at highest Pt (max-min): %s', strjoin(p.scheme_names(ord), ' > '));
    lines{end+1}=sprintf('Family gains (AmBC over baseline): OMA %.4f, NOMA %.4f, RSMA %.4f', ...
        local_pair_gain(row, p.scheme_names, 'Pure OMA', 'OMA-AmBC'), ...
        local_pair_gain(row, p.scheme_names, 'Pure NOMA', 'NOMA-AmBC'), ...
        local_pair_gain(row, p.scheme_names, 'Pure RSMA', 'RSMA-AmBC'));
    lines{end+1}=sprintf('RSMA vs NOMA (best family members): %.4f', ...
        local_best_of(row, p.scheme_names, {'Pure RSMA','RSMA-AmBC'}) - local_best_of(row, p.scheme_names, {'Pure NOMA','NOMA-AmBC'}));
end
if isfield(res_power,'rsma_opt_all_common_frac')
    lines{end+1}=sprintf('RSMA-opt all-common fraction (at reference Pt index): %.3f', res_power.rsma_opt_all_common_frac(idx40));
    lines{end+1}=sprintf('RSMA-opt avg alpha_c/alpha_1/alpha_2: %.3f / %.3f / %.3f', ...
        res_power.rsma_opt_alpha_c(idx40), res_power.rsma_opt_alpha_1(idx40), res_power.rsma_opt_alpha_2(idx40));
end
end

function print_scheme_metrics_local(p, res_power)
idx = find(p.Pt_dBm_vec == p.Pt_dBm_default, 1);
if isempty(idx), idx = numel(p.Pt_dBm_vec); end
exp_mode = local_get_or(p,'experiment_mode','research_rsma');
if strcmpi(exp_mode,'paper_reproduction')
    fprintf('\n=== Paper-mode scheme comparison at Pt=%.1f dBm (sum-rate objective) ===\n', p.Pt_dBm_vec(idx));
else
    fprintf('\n=== Research-mode scheme comparison at Pt=%.1f dBm (max-min objective) ===\n', p.Pt_dBm_vec(idx));
end
for is = 1:numel(p.scheme_names)
    base = sprintf('%s | sum-rate=%.4f | max-min=%.4f | rho=%.3f', ...
        p.scheme_names{is}, res_power.sum_rate(idx,is), res_power.max_min_rate(idx,is), res_power.rho_used(idx,is));
    if isfield(res_power,'scheme_avg_xi') && ~isnan(res_power.scheme_avg_xi(idx,is))
        base = sprintf('%s | xi=%.3f', base, res_power.scheme_avg_xi(idx,is));
    end
    if isfield(res_power,'scheme_avg_Pc') && ~isnan(res_power.scheme_avg_Pc(idx,is))
        base = sprintf('%s | Pc=%.4g P1=%.4g P2=%.4g | mu=%.3f', ...
            base, res_power.scheme_avg_Pc(idx,is), res_power.scheme_avg_P1(idx,is), res_power.scheme_avg_P2(idx,is), res_power.scheme_avg_mu(idx,is));
    end
    if isfield(res_power,'scheme_all_common_frac') && ~isnan(res_power.scheme_all_common_frac(idx,is))
        base = sprintf('%s | all-common-frac=%.3f', base, res_power.scheme_all_common_frac(idx,is));
    end
    fprintf('%s\n', base);
end
if isfield(res_power,'noma_opt_avg_rho')
    fprintf('[opt-stats] NOMA-opt avg rho=%.3f | hit-feasible=%.3f | skipped-infeasible=%.3f\n', ...
        res_power.noma_opt_avg_rho(idx), res_power.noma_opt_hit_feasible_frac(idx), res_power.noma_opt_skip_infeasible_frac(idx));
end
if isfield(res_power,'rsma_opt_avg_zeta')
    fprintf('[opt-stats] RSMA-opt avg zeta=%.3f | hit-feasible=%.3f | skipped-infeasible=%.3f | all-common=%.3f\n', ...
        res_power.rsma_opt_avg_zeta(idx), res_power.rsma_opt_hit_feasible_frac(idx), res_power.rsma_opt_skip_infeasible_frac(idx), res_power.rsma_opt_all_common_frac(idx));
    fprintf('[opt-stats] RSMA-opt avg alpha=(%.3f, %.3f, %.3f) | mu=%.3f | P=(%.4g, %.4g, %.4g)\n', ...
        res_power.rsma_opt_alpha_c(idx), res_power.rsma_opt_alpha_1(idx), res_power.rsma_opt_alpha_2(idx), ...
        res_power.rsma_opt_mu(idx), res_power.rsma_opt_Pc(idx), res_power.rsma_opt_P1(idx), res_power.rsma_opt_P2(idx));
end
fprintf('======================================\n\n');
end

function x=item(name,fig), x=struct('name',name,'fig',fig); end

function res = local_empty_result(kind, scheme_names)
res = struct();
res.x_values = [];
res.scheme_names = scheme_names;
res.sweep_name = kind;
res.x_label = '';
fns={'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for k=1:numel(fns), res.(fns{k}) = []; end
end


function sol = local_get_scheme_sol(sols, p, key)
% Keep summary/stat extraction robust to legacy-vs-current naming.
aliases = local_scheme_aliases(key);
idx = [];
for i = 1:numel(aliases)
    idx = find(strcmp(p.scheme_keys, aliases{i}), 1);
    if ~isempty(idx), break; end
end
if isempty(idx)
    sol = [];
else
    sol = sols{idx};
end
end

function aliases = local_scheme_aliases(key)
switch lower(key)
    case 'noma_opt'
        aliases = {'noma_opt','noma_ambc'};
    case 'rsma_opt'
        aliases = {'rsma_opt','rsma_ambc'};
    otherwise
        aliases = {key};
end
end


function g = local_pair_gain(row, names, base_name, ambc_name)
ib = find(strcmp(names, base_name), 1);
ia = find(strcmp(names, ambc_name), 1);
if isempty(ib) || isempty(ia), g = NaN; else, g = row(ia) - row(ib); end
end

function b = local_best_of(row, names, cand)
idx = find(ismember(names, cand));
if isempty(idx), b = NaN; else, b = max(row(idx)); end
end

function v = local_get_or(s, k, d)
if isfield(s, k), v = s.(k); else, v = d; end
end
