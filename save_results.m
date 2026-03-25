function save_results(cfg, figPower, figAlpha, tablePower, tableAlpha, resPower, resAlpha)
%SAVE_RESULTS Save figures and data files.

if ~exist(cfg.outDir, 'dir')
    mkdir(cfg.outDir);
end

saveas(figPower, fullfile(cfg.outDir, [cfg.figPowerName '.png']));
savefig(figPower, fullfile(cfg.outDir, [cfg.figPowerName '.fig']));

saveas(figAlpha, fullfile(cfg.outDir, [cfg.figAlphaName '.png']));
savefig(figAlpha, fullfile(cfg.outDir, [cfg.figAlphaName '.fig']));

writetable(tablePower, fullfile(cfg.outDir, cfg.csvPowerName));
writetable(tableAlpha, fullfile(cfg.outDir, cfg.csvAlphaName));

save(fullfile(cfg.outDir, 'all_results.mat'), 'cfg', 'resPower', 'resAlpha', 'tablePower', 'tableAlpha');

end
