function fig = plot_gain_curves(x, gain_abs, gain_rel, xlab, base_label, opt_label)
%PLOT_GAIN_CURVES Plot absolute and relative gain.

fig = figure('Color','w');
subplot(2,1,1);
plot(x, gain_abs, '-o', 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('Absolute gain');
title(sprintf('%s vs %s (absolute gain)', opt_label, base_label));

subplot(2,1,2);
plot(x, gain_rel, '-s', 'LineWidth', 1.6); grid on;
xlabel(xlab); ylabel('Relative gain (%)');
title(sprintf('%s vs %s (relative gain)', opt_label, base_label));

end
