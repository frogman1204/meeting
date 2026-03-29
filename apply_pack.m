function varargout = apply_pack(mode, varargin)
%APPLY_PACK Grouped apply/generate helpers.

switch lower(mode)
    case 'generate_channels'
        varargout{1} = core_ch();
    case 'apply_csi_error'
        varargout{1} = local_apply_csi_error(varargin{1}, varargin{2});
    case 'apply_blockage_effect'
        varargout{1} = local_apply_blockage(varargin{1}, varargin{2});
    otherwise
        error('Unknown apply mode: %s', mode);
end

end

function ch_e = local_apply_csi_error(ch, csi_err)
scale = @(x) x .* (1 + csi_err*randn);
ch_e = ch;
ch_e.hSR1 = scale(ch.hSR1);
ch_e.hSR2 = scale(ch.hSR2);
ch_e.hSF = scale(ch.hSF);
ch_e.gFR1 = scale(ch.gFR1);
ch_e.gFR2 = scale(ch.gFR2);
end

function ch_b = local_apply_blockage(ch, blk_loss_dB)
att = 10^(-blk_loss_dB/20);
ch_b = ch;
ch_b.hSR1 = ch.hSR1 * att;
ch_b.hSR2 = ch.hSR2 * att;
ch_b.hSF = ch.hSF * att;
ch_b.gFR1 = ch.gFR1 * att;
ch_b.gFR2 = ch.gFR2 * att;
end
