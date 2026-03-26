function res = run_sweep_rho(p)
%RUN_SWEEP_RHO Sweep reflection coefficient.

xvec = p.rho_plot_vec;
ns = numel(p.scheme_names); nx = numel(xvec);
res = struct();
fn={'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for k=1:numel(fn), res.(fn{k}) = nan(nx,ns); end

Pt = 10^((p.Pt_dBm_default-30)/10);
sic = p.sic_err_vec(1);

for ix=1:nx
    rho_now = xvec(ix);
    rho_grid_now = p.rho_grid(p.rho_grid <= rho_now);
    if isempty(rho_grid_now), rho_grid_now = rho_now; end
    tmp=zeros(p.numMC,ns,12);
    for imc=1:p.numMC
        ch=generate_channels(); ch=apply_csi_error(ch,p.csi_err_vec(1)); ch=apply_blockage_effect(ch,p.blk_loss_dB_vec(1));
        sols={solve_pure_noma(ch,Pt,sic,p.sigma2,p.rate_threshold), solve_noma_ambc_fixed(ch,Pt,sic,p.sigma2,rho_now,p.rate_threshold), solve_noma_ambc_opt(ch,Pt,sic,p.sigma2,rho_grid_now,p.rate_threshold), solve_pure_rsma(ch,Pt,sic,p.sigma2,p.rate_threshold), solve_rsma_ambc_fixed(ch,Pt,sic,p.sigma2,rho_now,p.rate_threshold), solve_rsma_ambc_opt(ch,Pt,sic,p.sigma2,rho_grid_now,p.rate_threshold)};
        for is=1:ns, s=sols{is}; tmp(imc,is,:)=[s.R1 s.R2 s.sum_rate s.max_min_rate s.jain_fairness s.energy_efficiency s.rho_used s.rho_opt s.ber_tag s.ber_user1 s.ber_user2 s.outage_flag]; end
    end
    avg=squeeze(mean(tmp,1));
    res.R1(ix,:)=avg(:,1)'; res.R2(ix,:)=avg(:,2)'; res.sum_rate(ix,:)=avg(:,3)'; res.max_min_rate(ix,:)=avg(:,4)';
    res.jain_fairness(ix,:)=avg(:,5)'; res.energy_efficiency(ix,:)=avg(:,6)'; res.rho_used(ix,:)=avg(:,7)'; res.rho_opt(ix,:)=avg(:,8)';
    res.ber_tag(ix,:)=avg(:,9)'; res.ber_user1(ix,:)=avg(:,10)'; res.ber_user2(ix,:)=avg(:,11)'; res.outage_flag(ix,:)=avg(:,12)';
end
res.x_values=xvec; res.scheme_names=p.scheme_names; res.sweep_name='rho'; res.x_label='Reflection coefficient rho';
end
