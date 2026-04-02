function varargout = apply_pack(mode, varargin)
%APPLY_PACK Grouped apply/generate helpers.
% Modes:
%   'generate_channels'     -> channel struct from core('ch', params)
%   'apply_csi_error'       -> imperfect-CSI: update estimated channels only
%   'apply_blockage_effect' -> blockage attenuation on true+estimated channels

switch lower(mode)
    case 'generate_channels'
        if nargin >= 2
            p = varargin{1};
        else
            p = struct();
        end
        varargout{1} = local_order_users(core('ch', p));
    case 'apply_csi_error'
        varargout{1} = local_apply_csi_error(varargin{1}, varargin{2});
    case 'apply_blockage_effect'
        varargout{1} = local_apply_blockage(varargin{1}, varargin{2});
    otherwise
        error('Unknown apply mode: %s', mode);
end

end

function ch_e = local_apply_csi_error(ch, csi_err)
% Keep true channels fixed; perturb estimated channels only.
ch_e = ch;
pert = @(x) sqrt(max(1-csi_err^2,0))*x + csi_err*((randn(size(x))+1i*randn(size(x)))/sqrt(2));
if isfield(ch,'h1_true')
    ch_e.h1_est = pert(ch.h1_true);
    ch_e.h2_est = pert(ch.h2_true);
    ch_e.hBT_est = pert(ch.hBT_true);
    ch_e.gT1_est = pert(ch.gT1_true);
    ch_e.gT2_est = pert(ch.gT2_true);
else
    % legacy fallback
    ch_e.hSR1 = pert(ch.hSR1);
    ch_e.hSR2 = pert(ch.hSR2);
    ch_e.hSF = pert(ch.hSF);
    ch_e.gFR1 = pert(ch.gFR1);
    ch_e.gFR2 = pert(ch.gFR2);
end
ch_e = local_refresh_aliases(ch_e);
ch_e = local_order_users(ch_e);
end

function ch_b = local_apply_blockage(ch, blk_loss_dB)
att = 10^(-blk_loss_dB/20);
ch_b = ch;
if isfield(ch,'h1_true')
    ch_b.h1_true = ch.h1_true * att; ch_b.h2_true = ch.h2_true * att; ch_b.hBT_true = ch.hBT_true * att;
    ch_b.h1_est = ch.h1_est * att;   ch_b.h2_est = ch.h2_est * att;   ch_b.hBT_est = ch.hBT_est * att;
    ch_b.gT1_true = ch.gT1_true * att; ch_b.gT2_true = ch.gT2_true * att;
    ch_b.gT1_est = ch.gT1_est * att;   ch_b.gT2_est = ch.gT2_est * att;
else
    ch_b.hSR1 = ch.hSR1 * att; ch_b.hSR2 = ch.hSR2 * att; ch_b.hSF = ch.hSF * att;
    ch_b.gFR1 = ch.gFR1 * att; ch_b.gFR2 = ch.gFR2 * att;
end
ch_b = local_refresh_aliases(ch_b);
ch_b = local_order_users(ch_b);
end

function ch_o = local_order_users(ch)
% Ensure near/far ordering by direct-link power (true channel norm).
ch_o = ch;
if isfield(ch,'h1_true')
    if norm(ch.h1_true)^2 < norm(ch.h2_true)^2
        [ch_o.h1_true, ch_o.h2_true] = deal(ch.h2_true, ch.h1_true);
        [ch_o.h1_est, ch_o.h2_est] = deal(ch.h2_est, ch.h1_est);
        [ch_o.gT1_true, ch_o.gT2_true] = deal(ch.gT2_true, ch.gT1_true);
        [ch_o.gT1_est, ch_o.gT2_est] = deal(ch.gT2_est, ch.gT1_est);
    end
else
    if abs(ch.hSR1)^2 < abs(ch.hSR2)^2
        ch_o.hSR1 = ch.hSR2; ch_o.hSR2 = ch.hSR1;
        ch_o.gFR1 = ch.gFR2; ch_o.gFR2 = ch.gFR1;
    end
end
ch_o = local_refresh_aliases(ch_o);
end

function ch = local_refresh_aliases(ch)
if ~isfield(ch,'h1_true'), return; end
% Legacy scalar aliases kept for compatibility with existing helpers.
ch.hSR1 = norm(ch.h1_true);
ch.hSR2 = norm(ch.h2_true);
ch.hSF = norm(ch.hBT_true);
ch.gFR1 = ch.gT1_true;
ch.gFR2 = ch.gT2_true;
end
