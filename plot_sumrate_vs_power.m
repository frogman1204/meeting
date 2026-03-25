function fig = plot_sumrate_vs_power(psDbmList, avgSumRate, schemeList)
%PLOT_SUMRATE_VS_POWER Plot average sum-rate versus source power.

fig = figure('Color', 'w');
plot(psDbmList, avgSumRate(:, 1), '-o', 'LineWidth', 1.5); hold on;
plot(psDbmList, avgSumRate(:, 2), '-s', 'LineWidth', 1.5);
plot(psDbmList, avgSumRate(:, 3), '-^', 'LineWidth', 1.5);
grid on;
xlabel('Source available power P_s (dBm)');
ylabel('Average sum-rate (bit/s/Hz)');
title('Sum-rate vs Source Power');
legend(schemeList, 'Location', 'best');

end
