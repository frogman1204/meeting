function res = run_sweep_csi(p)
%RUN_SWEEP_CSI Sweep CSI error.
res = local_sweep(p.csi_err_vec, p, 'csi');
res.sweep_name = 'csi';
res.x_label = 'CSI error level';
end

function res = local_sweep(xvec, p, mode)
res = local_template(xvec,p);
for ix=1:numel(xvec)
    Pt = 10^((p.Pt_dBm_default-30)/10);
    sic_err = p.sic_err_vec(1);
    csi_err = xvec(ix);
    blk = p.blk_loss_dB_vec(1);
    res = local_fill(ix,res,p,Pt,sic_err,csi_err,blk,p.rho_fixed,p.rho_grid);
end
res.x_values=xvec; res.scheme_names=p.scheme_names;
end

function res=local_template(x,p)
ns=numel(p.scheme_names); nx=numel(x);
fn={'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for k=1:numel(fn), res.(fn{k})=nan(nx,ns); end
end

function res=local_fill(ix,res,p,Pt,sic_err,csi_err,blk,rho_fixed,rho_grid)
ns=numel(p.scheme_names); tmp=zeros(p.numMC,ns,12);
for imc=1:p.numMC
 ch=generate_channels(); ch=apply_csi_error(ch,csi_err); ch=apply_blockage_effect(ch,blk);
 sols={solve_pure_noma(ch,Pt,sic_err,p.sigma2,p.rate_threshold), ...
 solve_noma_ambc_fixed(ch,Pt,sic_err,p.sigma2,rho_fixed,p.rate_threshold), ...
 solve_noma_ambc_opt(ch,Pt,sic_err,p.sigma2,rho_grid,p.rate_threshold), ...
 solve_pure_rsma(ch,Pt,sic_err,p.sigma2,p.rate_threshold), ...
 solve_rsma_ambc_fixed(ch,Pt,sic_err,p.sigma2,rho_fixed,p.rate_threshold), ...
 solve_rsma_ambc_opt(ch,Pt,sic_err,p.sigma2,rho_grid,p.rate_threshold)};
 for is=1:ns
  s=sols{is}; tmp(imc,is,:)=[s.R1 s.R2 s.sum_rate s.max_min_rate s.jain_fairness s.energy_efficiency s.rho_used s.rho_opt s.ber_tag s.ber_user1 s.ber_user2 s.outage_flag];
 end
end
avg=squeeze(mean(tmp,1));
res.R1(ix,:)=avg(:,1)'; res.R2(ix,:)=avg(:,2)'; res.sum_rate(ix,:)=avg(:,3)'; res.max_min_rate(ix,:)=avg(:,4)';
res.jain_fairness(ix,:)=avg(:,5)'; res.energy_efficiency(ix,:)=avg(:,6)'; res.rho_used(ix,:)=avg(:,7)'; res.rho_opt(ix,:)=avg(:,8)';
res.ber_tag(ix,:)=avg(:,9)'; res.ber_user1(ix,:)=avg(:,10)'; res.ber_user2(ix,:)=avg(:,11)'; res.outage_flag(ix,:)=avg(:,12)';
end
