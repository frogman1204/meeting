function f = plt_p(pVec, aS, sch)
%PLT_P Sum-rate vs power.

f = figure('Color','w');
plot(pVec, aS(:,1), '-o', 'LineWidth',1.5); hold on;
plot(pVec, aS(:,2), '-s', 'LineWidth',1.5);
plot(pVec, aS(:,3), '-^', 'LineWidth',1.5);
grid on; xlabel('Source available power P_s (dBm)'); ylabel('Average sum-rate (bit/s/Hz)');
title('Sum-rate vs Source Power'); legend(sch, 'Location','best');

end
