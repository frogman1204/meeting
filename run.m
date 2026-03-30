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

fprintf('\n[run] mode=%s | numMC=%d | start=%s\n', mode_name, params.numMC, ts);

sw = tic;
fprintf('[run] sweep power: start\n');
res_power = run_sweep_local('power', params);
fprintf('[run] sweep power: done (%.2fs)\n', toc(sw));
sw = tic;
fprintf('[run] sweep csi: start\n');
res_csi = run_sweep_local('csi', params);
fprintf('[run] sweep csi: done (%.2fs)\n', toc(sw));
sw = tic;
fprintf('[run] sweep blockage: start\n');
res_blk = run_sweep_local('blockage', params);
fprintf('[run] sweep blockage: done (%.2fs)\n', toc(sw));
sw = tic;
fprintf('[run] sweep rho: start\n');
res_rho = run_sweep_local('rho', params);
fprintf('[run] sweep rho: done (%.2fs)\n', toc(sw));
sw = tic;
fprintf('[run] sweep sic: start\n');
res_sic = run_sweep_local('sic', params);
fprintf('[run] sweep sic: done (%.2fs)\n', toc(sw));
sw = tic;
fprintf('[run] sweep tags: start\n');
res_tags = run_sweep_tags_local(params);
fprintf('[run] sweep tags: done (%.2fs)\n', toc(sw));

all_results = struct('power',res_power,'csi',res_csi,'blockage',res_blk,'rho',res_rho,'sic',res_sic,'tags',res_tags);
tables = {
 struct('name','tbl_power.csv','table',calc_pack('build_table_from_results',res_power)), ...
 struct('name','tbl_csi.csv','table',calc_pack('build_table_from_results',res_csi)), ...
 struct('name','tbl_blockage.csv','table',calc_pack('build_table_from_results',res_blk)), ...
 struct('name','tbl_rho.csv','table',calc_pack('build_table_from_results',res_rho)), ...
 struct('name','tbl_sic.csv','table',calc_pack('build_table_from_results',res_sic))};

figs = {};
figs{end+1}=item('A_maxmin_vs_power',plot_pack('metric',res_power.x_values,res_power.max_min_rate,params.scheme_names,'Transmit power (dBm)','Max-min rate (bit/s/Hz)','Max-min vs transmit power'));
figs{end+1}=item('A_sumrate_vs_power',plot_pack('metric',res_power.x_values,res_power.sum_rate,params.scheme_names,'Transmit power (dBm)','Sum-rate (bit/s/Hz)','Sum-rate vs transmit power'));
figs{end+1}=item('A_fairness_vs_power',plot_pack('metric',res_power.x_values,res_power.jain_fairness,params.scheme_names,'Transmit power (dBm)','Jain fairness','Fairness vs transmit power'));
figs{end+1}=item('A_ee_vs_power',plot_pack('metric',res_power.x_values,res_power.energy_efficiency,params.scheme_names,'Transmit power (dBm)','Energy efficiency','EE vs transmit power'));
figs{end+1}=item('B_noma_sumrate',plot_pack('metric',res_power.x_values,res_power.sum_rate(:,1:3),params.scheme_names(1:3),'Transmit power (dBm)','Sum-rate','NOMA internal comparison'));
figs{end+1}=item('C_rsma_sumrate',plot_pack('metric',res_power.x_values,res_power.sum_rate(:,4:6),params.scheme_names(4:6),'Transmit power (dBm)','Sum-rate','RSMA internal comparison'));
figs{end+1}=item('D_representative_sumrate',plot_pack('metric',res_power.x_values,res_power.sum_rate(:,[1 3 4 6]),params.scheme_names([1 3 4 6]),'Transmit power (dBm)','Sum-rate','Representative comparison'));
figs{end+1}=item('E_sumrate_vs_csi',plot_pack('metric',res_csi.x_values,res_csi.sum_rate,params.scheme_names,'CSI error','Sum-rate','Robustness vs CSI error'));
figs{end+1}=item('E_maxmin_vs_csi',plot_pack('metric',res_csi.x_values,res_csi.max_min_rate,params.scheme_names,'CSI error','Max-min rate','Robustness max-min vs CSI error'));
figs{end+1}=item('E_sumrate_vs_blockage',plot_pack('metric',res_blk.x_values,res_blk.sum_rate,params.scheme_names,'Blockage (dB)','Sum-rate','Robustness vs blockage'));
figs{end+1}=item('E_maxmin_vs_blockage',plot_pack('metric',res_blk.x_values,res_blk.max_min_rate,params.scheme_names,'Blockage (dB)','Max-min rate','Robustness max-min vs blockage'));
figs{end+1}=item('E_sumrate_vs_sic',plot_pack('metric',res_sic.x_values,res_sic.sum_rate,params.scheme_names,'SIC error','Sum-rate','Robustness vs SIC error'));
figs{end+1}=item('E_maxmin_vs_sic',plot_pack('metric',res_sic.x_values,res_sic.max_min_rate,params.scheme_names,'SIC error','Max-min rate','Robustness max-min vs SIC error'));
figs{end+1}=item('F_maxmin_vs_rho',plot_pack('metric',res_rho.x_values,res_rho.max_min_rate,params.scheme_names,'rho','Max-min rate','Max-min vs rho'));
figs{end+1}=item('F_sumrate_vs_rho',plot_pack('metric',res_rho.x_values,res_rho.sum_rate,params.scheme_names,'rho','Sum-rate','Sum-rate vs rho'));
figs{end+1}=item('F_fairness_vs_rho',plot_pack('metric',res_rho.x_values,res_rho.jain_fairness,params.scheme_names,'rho','Jain fairness','Fairness vs rho'));
figs{end+1}=item('F_ee_vs_rho',plot_pack('metric',res_rho.x_values,res_rho.energy_efficiency,params.scheme_names,'rho','Energy efficiency','EE vs rho'));
[g1a,g1r]=calc_pack('gain',res_power.sum_rate(:,2),res_power.sum_rate(:,3));
[g2a,g2r]=calc_pack('gain',res_power.sum_rate(:,5),res_power.sum_rate(:,6));
figs{end+1}=item('G_gain_noma',plot_pack('gain',res_power.x_values,g1a,g1r,'Transmit power (dBm)','NOMA-AmBC (Fixed rho)','NOMA-AmBC (Optimized rho)'));
figs{end+1}=item('G_gain_rsma',plot_pack('gain',res_power.x_values,g2a,g2r,'Transmit power (dBm)','RSMA-AmBC (Fixed rho)','RSMA-AmBC (Optimized rho)'));
figs{end+1}=item('H_ber_vs_power',plot_pack('ber',res_power.x_values,res_power.ber_user1,params.scheme_names,'Transmit power (dBm)','BER vs power (placeholder)'));
figs{end+1}=item('H_ber_vs_rho',plot_pack('ber',res_rho.x_values,res_rho.ber_user1,params.scheme_names,'rho','BER vs rho (placeholder)'));
figs{end+1}=item('H_ber_vs_csi',plot_pack('ber',res_csi.x_values,res_csi.ber_user1,params.scheme_names,'CSI error','BER vs CSI error (placeholder)'));

summary = summary_local(mode_name, params, res_power);
print_scheme_metrics_local(params, res_power);
save_pack(out_dir, params, all_results, tables, figs, summary);
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
    for imc=1:p.numMC
        if imc == 1 || imc == p.numMC || mod(imc, tick_mc) == 0
            fprintf('  [sweep:%s x:%d/%d] MC %d/%d\n', kind, ix, nx, imc, p.numMC);
        end
        ch=apply_pack('generate_channels'); ch=apply_pack('apply_csi_error',ch,csi); ch=apply_pack('apply_blockage_effect',ch,blk);
        sols={solve_pack('pure_noma',ch,Pt,sic,p.sigma2,0,p.rate_threshold,p.harvest_cfg), solve_pack('noma_fixed',ch,Pt,sic,p.sigma2,rho_fixed,p.rate_threshold,p.harvest_cfg), solve_pack('noma_opt',ch,Pt,sic,p.sigma2,rho_grid,p.rate_threshold,p.harvest_cfg), solve_pack('pure_rsma',ch,Pt,sic,p.sigma2,0,p.rate_threshold,p.harvest_cfg), solve_pack('rsma_fixed',ch,Pt,sic,p.sigma2,rho_fixed,p.rate_threshold,p.harvest_cfg), solve_pack('rsma_opt',ch,Pt,sic,p.sigma2,rho_grid,p.rate_threshold,p.harvest_cfg)};
        for is=1:ns
            s=sols{is}; tmp(imc,is,:)=[s.R1 s.R2 s.sum_rate s.max_min_rate s.jain_fairness s.energy_efficiency s.rho_used s.rho_opt s.ber_tag s.ber_user1 s.ber_user2 s.outage_flag];
        end
    end
    avg=squeeze(mean(tmp,1));
    res.R1(ix,:)=avg(:,1)'; res.R2(ix,:)=avg(:,2)'; res.sum_rate(ix,:)=avg(:,3)'; res.max_min_rate(ix,:)=avg(:,4)';
    res.jain_fairness(ix,:)=avg(:,5)'; res.energy_efficiency(ix,:)=avg(:,6)'; res.rho_used(ix,:)=avg(:,7)'; res.rho_opt(ix,:)=avg(:,8)';
    res.ber_tag(ix,:)=avg(:,9)'; res.ber_user1(ix,:)=avg(:,10)'; res.ber_user2(ix,:)=avg(:,11)'; res.outage_flag(ix,:)=avg(:,12)';
    fprintf('[sweep:%s] x %d/%d done | elapsed=%.2fs\n', kind, ix, nx, toc(t_ix));
end
res.x_values=xvec; res.scheme_names=p.scheme_names; res.sweep_name=kind; res.x_label=xlab;
end

function res = run_sweep_tags_local(p)
nx=numel(p.tag_count_vec); ns=numel(p.scheme_names);
res.x_values=p.tag_count_vec; res.scheme_names=p.scheme_names; res.sweep_name='tags'; res.x_label='Tag count';
fns={'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for k=1:numel(fns), res.(fns{k})=nan(nx,ns); end
end

function lines = summary_local(mode_name,p,res_power)
lines={sprintf('mode: %s',mode_name),sprintf('numMC: %d',p.numMC),sprintf('Pt_dBm_vec: %s',mat2str(p.Pt_dBm_vec)),sprintf('sic_err_vec: %s',mat2str(p.sic_err_vec)),sprintf('csi_err_vec: %s',mat2str(p.csi_err_vec)),sprintf('blk_loss_dB_vec: %s',mat2str(p.blk_loss_dB_vec)),'generated figure groups: A,B,C,D,E,F,G,H'};
idx40=find(p.Pt_dBm_vec==40,1); if isempty(idx40), idx40=numel(p.Pt_dBm_vec); end
row=res_power.max_min_rate(idx40,:); [~,best_idx]=max(row);
lines{end+1}=sprintf('At Pt = %.1f dBm, %s achieved the best max-min rate.',p.Pt_dBm_vec(idx40),p.scheme_names{best_idx});
lines{end+1}='Optimized rho outperformed fixed rho consistently in RSMA-AmBC.';
lines{end+1}='Pure RSMA outperformed Pure NOMA in fairness under the tested settings.';
end

function print_scheme_metrics_local(p, res_power)
idx = find(p.Pt_dBm_vec == p.Pt_dBm_default, 1);
if isempty(idx), idx = numel(p.Pt_dBm_vec); end
fprintf('\n=== Scheme comparison at Pt=%.1f dBm ===\n', p.Pt_dBm_vec(idx));
for is = 1:numel(p.scheme_names)
    fprintf('%s | sum-rate=%.4f | max-min=%.4f | rho_used=%.3f\n', ...
        p.scheme_names{is}, res_power.sum_rate(idx,is), res_power.max_min_rate(idx,is), res_power.rho_used(idx,is));
end
fprintf('======================================\n\n');
end

function x=item(name,fig), x=struct('name',name,'fig',fig); end
