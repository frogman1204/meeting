function fa = plt_a(aVec, aS, sch)
%PLT_A Sum-rate vs alpha.

fa = figure('Color','w');
plot(aVec, aS(:,1), '-o', 'LineWidth',1.5); hold on;
plot(aVec, aS(:,2), '-s', 'LineWidth',1.5);
plot(aVec, aS(:,3), '-^', 'LineWidth',1.5);
grid on; xlabel('Imperfect SIC parameter \alpha'); ylabel('Average sum-rate (bit/s/Hz)');
title('Sum-rate vs Imperfect SIC Parameter'); legend(sch, 'Location','best');

end
