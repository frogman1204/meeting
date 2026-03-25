function f = plt(mode, x, aS, sch)
%PLT Grouped plotting helpers: plt_p, plt_a.

switch lower(mode)
    case 'p'
        f = plt_p(x, aS, sch);
    case 'a'
        f = plt_a(x, aS, sch);
    otherwise
        error('Unknown plt mode: %s', mode);
end

end

function f = plt_p(pVec, aS, sch)
f = figure('Color','w');
plot(pVec, aS(:,1), '-o', 'LineWidth',1.5); hold on;
plot(pVec, aS(:,2), '-s', 'LineWidth',1.5);
plot(pVec, aS(:,3), '-^', 'LineWidth',1.5);
grid on; xlabel('Source available power P_s (dBm)'); ylabel('Average sum-rate (bit/s/Hz)');
title('Sum-rate vs Source Power'); legend(sch, 'Location','best');
end

function f = plt_a(aVec, aS, sch)
f = figure('Color','w');
plot(aVec, aS(:,1), '-o', 'LineWidth',1.5); hold on;
plot(aVec, aS(:,2), '-s', 'LineWidth',1.5);
plot(aVec, aS(:,3), '-^', 'LineWidth',1.5);
grid on; xlabel('Imperfect SIC parameter \alpha'); ylabel('Average sum-rate (bit/s/Hz)');
title('Sum-rate vs Imperfect SIC Parameter'); legend(sch, 'Location','best');
end
