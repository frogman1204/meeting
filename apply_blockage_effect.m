function ch_b = apply_blockage_effect(ch, blk_loss_dB)
%APPLY_BLOCKAGE_EFFECT Apply blockage attenuation.

att = 10^(-blk_loss_dB/20);
ch_b = ch;
ch_b.hSR1 = ch.hSR1 * att;
ch_b.hSR2 = ch.hSR2 * att;
ch_b.hSF = ch.hSF * att;
ch_b.gFR1 = ch.gFR1 * att;
ch_b.gFR2 = ch.gFR2 * att;

end
