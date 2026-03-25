function fig = plot_sumrate_vs_alpha(alphaList, avgSumRate, schemeList)
%PLOT_SUMRATE_VS_ALPHA Plot average sum-rate versus imperfect SIC alpha.

fig = figure('Color', 'w');
plot(alphaList, avgSumRate(:, 1), '-o', 'LineWidth', 1.5); hold on;
plot(alphaList, avgSumRate(:, 2), '-s', 'LineWidth', 1.5);
plot(alphaList, avgSumRate(:, 3), '-^', 'LineWidth', 1.5);
grid on;
xlabel('Imperfect SIC parameter \alpha');
ylabel('Average sum-rate (bit/s/Hz)');
title('Sum-rate vs Imperfect SIC Parameter');
legend(schemeList, 'Location', 'best');

end
