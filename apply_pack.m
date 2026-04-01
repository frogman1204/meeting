function varargout = apply_pack(mode, varargin)
%APPLY_PACK Grouped apply/generate helpers.
% Modes:
%   'generate_channels'  -> output channel struct from core('ch')
%   'apply_csi_error'    -> apply multiplicative CSI error model
%   'apply_blockage_effect' -> apply blockage attenuation in dB
% Near/far ordering is enforced after each stage.

switch lower(mode)
    case 'generate_channels'
        varargout{1} = local_order_users(core('ch'));
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
ch_e = local_order_users(ch_e);
end

function ch_b = local_apply_blockage(ch, blk_loss_dB)
att = 10^(-blk_loss_dB/20);
ch_b = ch;
ch_b.hSR1 = ch.hSR1 * att;
ch_b.hSR2 = ch.hSR2 * att;
ch_b.hSF = ch.hSF * att;
ch_b.gFR1 = ch.gFR1 * att;
ch_b.gFR2 = ch.gFR2 * att;
ch_b = local_order_users(ch_b);
end

function ch_o = local_order_users(ch)
% Ensure near/far ordering: user1 has stronger direct link than user2.
ch_o = ch;
if abs(ch.hSR1)^2 < abs(ch.hSR2)^2
    ch_o.hSR1 = ch.hSR2;
    ch_o.hSR2 = ch.hSR1;
    ch_o.gFR1 = ch.gFR2;
    ch_o.gFR2 = ch.gFR1;
end
end
