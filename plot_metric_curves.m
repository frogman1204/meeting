function fig = plot_metric_curves(x, Y, legend_names, xlab, ylab, ttl)
%PLOT_METRIC_CURVES Generic multi-curve plot.

fig = figure('Color','w');
plot(x, Y, 'LineWidth', 1.6);
grid on;
xlabel(xlab);
ylabel(ylab);
title(ttl);
legend(legend_names, 'Location', 'bestoutside');

end
