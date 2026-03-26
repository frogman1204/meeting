function res = run_sweep_power(p)
%RUN_SWEEP_POWER Sweep transmit power.

xvec = p.Pt_dBm_vec;
res = local_run_generic_sweep(xvec, p, 'power');
res.sweep_name = 'power';
res.x_label = 'Transmit power (dBm)';

end

function res = local_run_generic_sweep(xvec, p, mode)
ns = numel(p.scheme_names);
nx = numel(xvec);

R1 = zeros(nx, ns); R2 = zeros(nx, ns); SUM = zeros(nx, ns);
MM = zeros(nx, ns); J = zeros(nx, ns); EE = zeros(nx, ns);
RHO = zeros(nx, ns); RHOOPT = nan(nx, ns);
BERt = nan(nx, ns); BER1 = nan(nx, ns); BER2 = nan(nx, ns); OUT = zeros(nx, ns);

for ix = 1:nx
    if strcmp(mode, 'power')
        Pt = 10^((xvec(ix)-30)/10);
        sic_err = p.sic_err_vec(1);
        csi_err = p.csi_err_vec(1);
        blk = p.blk_loss_dB_vec(1);
    else
        Pt = 10^((p.Pt_dBm_default-30)/10);
        sic_err = p.sic_err_vec(1);
        csi_err = p.csi_err_vec(1);
        blk = p.blk_loss_dB_vec(1);
    end

    tmp = zeros(p.numMC, ns, 12);
    for imc = 1:p.numMC
        ch = generate_channels();
        ch = apply_csi_error(ch, csi_err);
        ch = apply_blockage_effect(ch, blk);
        sols = local_all_schemes(ch, Pt, sic_err, p, p.rho_fixed, p.rho_grid);
        for is = 1:ns
            s = sols{is};
            tmp(imc, is, :) = [s.R1 s.R2 s.sum_rate s.max_min_rate s.jain_fairness s.energy_efficiency ...
                s.rho_used s.rho_opt s.ber_tag s.ber_user1 s.ber_user2 s.outage_flag];
        end
    end

    avg = squeeze(mean(tmp,1));
    R1(ix,:) = avg(:,1)'; R2(ix,:) = avg(:,2)'; SUM(ix,:) = avg(:,3)'; MM(ix,:) = avg(:,4)';
    J(ix,:) = avg(:,5)'; EE(ix,:) = avg(:,6)'; RHO(ix,:) = avg(:,7)'; RHOOPT(ix,:) = avg(:,8)';
    BERt(ix,:) = avg(:,9)'; BER1(ix,:) = avg(:,10)'; BER2(ix,:) = avg(:,11)'; OUT(ix,:) = avg(:,12)';
end

res.x_values = xvec;
res.scheme_names = p.scheme_names;
res.R1 = R1; res.R2 = R2; res.sum_rate = SUM; res.max_min_rate = MM; res.jain_fairness = J;
res.energy_efficiency = EE; res.rho_used = RHO; res.rho_opt = RHOOPT;
res.ber_tag = BERt; res.ber_user1 = BER1; res.ber_user2 = BER2; res.outage_flag = OUT;

end

function sols = local_all_schemes(ch, Pt, sic_err, p, rho_fixed, rho_grid)
sols = cell(1,6);
sols{1} = solve_pure_noma(ch, Pt, sic_err, p.sigma2, p.rate_threshold);
sols{2} = solve_noma_ambc_fixed(ch, Pt, sic_err, p.sigma2, rho_fixed, p.rate_threshold);
sols{3} = solve_noma_ambc_opt(ch, Pt, sic_err, p.sigma2, rho_grid, p.rate_threshold);
sols{4} = solve_pure_rsma(ch, Pt, sic_err, p.sigma2, p.rate_threshold);
sols{5} = solve_rsma_ambc_fixed(ch, Pt, sic_err, p.sigma2, rho_fixed, p.rate_threshold);
sols{6} = solve_rsma_ambc_opt(ch, Pt, sic_err, p.sigma2, rho_grid, p.rate_threshold);
end
