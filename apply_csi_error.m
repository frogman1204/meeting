function ch_e = apply_csi_error(ch, csi_err)
%APPLY_CSI_ERROR Apply simple multiplicative CSI error model.

scale = @(x) x .* (1 + csi_err*randn);
ch_e = ch;
ch_e.hSR1 = scale(ch.hSR1);
ch_e.hSR2 = scale(ch.hSR2);
ch_e.hSF = scale(ch.hSF);
ch_e.gFR1 = scale(ch.gFR1);
ch_e.gFR2 = scale(ch.gFR2);

end
