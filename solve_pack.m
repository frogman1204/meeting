function met = solve_pack(mode, ch, Pt, sic_err, sigma2, rho_arg, rate_threshold)
%SOLVE_PACK Router between NOMA baseline and RSMA proposed modules.

switch lower(mode)
    case 'pure_noma'
        met = noma_baseline_pack('pure', ch, Pt, sic_err, sigma2, 0, rate_threshold);
    case 'noma_fixed'
        met = noma_baseline_pack('fixed', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold);
    case 'noma_opt'
        met = noma_baseline_pack('opt', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold);
    case 'pure_rsma'
        met = rsma_proposed_pack('pure', ch, Pt, sic_err, sigma2, 0, rate_threshold);
    case 'rsma_fixed'
        met = rsma_proposed_pack('fixed', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold);
    case 'rsma_opt'
        met = rsma_proposed_pack('opt', ch, Pt, sic_err, sigma2, rho_arg, rate_threshold);
    otherwise
        error('Unknown solve mode: %s', mode);
end

end
