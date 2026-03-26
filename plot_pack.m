function fig = plot_pack(mode, varargin)
%PLOT_PACK Grouped plotting functions.

switch lower(mode)
    case 'metric'
        fig = local_metric(varargin{:});
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

function fig = local_gain_plot(x, gain_abs, gain_rel, xlab, base_label, opt_label)
fig = figure('Color','w');
subplot(2,1,1); plot(x, gain_abs, '-o', 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('Absolute gain'); title(sprintf('%s vs %s (absolute gain)', opt_label, base_label));
subplot(2,1,2); plot(x, gain_rel, '-s', 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('Relative gain (%)'); title(sprintf('%s vs %s (relative gain)', opt_label, base_label));
end

function fig = local_ber(x, ber_mat, legend_names, xlab, ttl)
fig = figure('Color','w');
plot(x, ber_mat, 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('BER'); title(ttl);
legend(legend_names, 'Location', 'bestoutside');
end
