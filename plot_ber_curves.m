function fig = plot_ber_curves(x, ber_mat, legend_names, xlab, ttl)
%PLOT_BER_CURVES Plot BER placeholders.

fig = figure('Color','w');
plot(x, ber_mat, 'LineWidth', 1.6);
grid on;
xlabel(xlab);
ylabel('BER');
title(ttl);
legend(legend_names, 'Location', 'bestoutside');

end
