function fig = plot_pack(mode, varargin)
%PLOT_PACK Grouped plotting functions.
% Modes:
%   'metric' : generic metric curves
%   'gain'   : absolute/relative gain subplot
%   'ber'    : BER (placeholder-capable) curves

switch lower(mode)
    case 'metric'
        fig = local_metric(varargin{:});
    case 'metric_main6'
        fig = local_metric_main6(varargin{:});
    case 'metric_sic4'
        fig = local_metric_sic4(varargin{:});
    case 'gain'
        fig = local_gain_plot(varargin{:});
    case 'ber'
        fig = local_ber(varargin{:});
    otherwise
        error('Unknown plot mode: %s', mode);
end

end

function fig = local_metric(x, Y, legend_names, xlab, ylab, ttl)
fig = figure('Color','w');
plot(x, Y, 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel(ylab); title(ttl);
legend(legend_names, 'Location', 'bestoutside');
end


function fig = local_metric_main6(x, Y, legend_names, xlab, ylab, ttl)
% Publication-style main comparison plot for the 6 research schemes.
fig = figure('Color','w');
ax = axes(fig); hold(ax, 'on');
markers = {'v','>','o','s','d','^'};
for i = 1:min(6, size(Y,2))
    plot(ax, x, Y(:,i), ['-' markers{i}], 'LineWidth', 1.8, 'MarkerSize', 7);
end
grid(ax, 'on'); box(ax, 'on');
set(ax, 'FontName', 'Times New Roman');
xlabel(xlab); ylabel(ylab); title(ttl);
legend(legend_names(1:min(6,end)), 'Location', 'best');
local_annotate_gap_gain(ax, x, Y, legend_names);
hold(ax, 'off');
end


function fig = local_metric_sic4(x, Y, legend_names, xlab, ylab, ttl)
fig = figure('Color','w');
ax = axes(fig); hold(ax, 'on');
markers = {'o','s','d','^'};
for i = 1:min(4, size(Y,2))
    plot(ax, x, Y(:,i), ['-' markers{i}], 'LineWidth', 1.8, 'MarkerSize', 7);
end
grid(ax,'on'); box(ax,'on');
set(ax,'FontName','Times New Roman');
xlabel(xlab); ylabel(ylab); title(ttl);
legend(legend_names(1:min(4,end)), 'Location', 'best');
hold(ax,'off');
end

function local_annotate_gap_gain(ax, x, Y, legend_names)
if isempty(x) || size(Y,1) ~= numel(x), return; end
x0 = x(end);
pairs = {
    'Pure SDMA', 'SDMA-AmBC';
    'Pure NOMA', 'NOMA-AmBC';
    'Pure RSMA', 'RSMA-AmBC'
};
dx = 0.02 * max(1, max(x)-min(x));
for ip = 1:size(pairs,1)
    ib = find(strcmp(legend_names, pairs{ip,1}), 1);
    io = find(strcmp(legend_names, pairs{ip,2}), 1);
    if isempty(ib) || isempty(io), continue; end
    yb = Y(end, ib); yo = Y(end, io);
    if ~isfinite(yb) || ~isfinite(yo), continue; end
    y1 = min(yb, yo); y2 = max(yb, yo);
    xk = x0 + (ip-2)*dx;
    line(ax, [xk xk], [y1 y2], 'Color', [0.15 0.15 0.15], 'LineStyle', '-', 'LineWidth', 1.6);
    line(ax, [xk-0.15*dx xk+0.15*dx], [y1 y1], 'Color', [0.15 0.15 0.15], 'LineWidth', 1.6);
    line(ax, [xk-0.15*dx xk+0.15*dx], [y2 y2], 'Color', [0.15 0.15 0.15], 'LineWidth', 1.6);
    dabs = yo - yb; drel = 100 * dabs / max(abs(yb), 1e-9);
    txt = sprintf('%+.2f bps/Hz (%+.1f%%)', dabs, drel);
    yt = y2 + 0.03*(max(Y(:))-min(Y(:))+eps) + 0.02*(ip-1)*(max(Y(:))-min(Y(:))+eps);
    text(ax, xk + 0.05*dx, yt, txt, 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.05 0.05 0.05]);
end
end

function fig = local_gain_plot(x, gain_abs, gain_rel, xlab, base_label, opt_label)
fig = figure('Color','w');
subplot(2,1,1); plot(x, gain_abs, '-o', 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('Absolute gain'); title(sprintf('%s vs %s (absolute gain)', opt_label, base_label));
subplot(2,1,2); plot(x, gain_rel, '-s', 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('Relative gain (%)'); title(sprintf('%s vs %s (relative gain)', opt_label, base_label));
end

function fig = local_ber(x, ber_mat, legend_names, xlab, ttl)
fig = figure('Color','w');
ber_plot = max(ber_mat, 1e-6);
semilogy(x, ber_plot, 'LineWidth', 1.8); grid on;
xlabel(xlab); ylabel('BER'); title(ttl);
legend(legend_names, 'Location', 'bestoutside');
end
