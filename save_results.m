function save_results(outDir, figPowerName, figAlphaName, csvPowerName, csvAlphaName, ...
    figPower, figAlpha, tablePower, tableAlpha, allDataName, rawData)
%SAVE_RESULTS Save figures and data files.

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

saveas(figPower, fullfile(outDir, [figPowerName '.png']));
savefig(figPower, fullfile(outDir, [figPowerName '.fig']));

saveas(figAlpha, fullfile(outDir, [figAlphaName '.png']));
savefig(figAlpha, fullfile(outDir, [figAlphaName '.fig']));

writetable(tablePower, fullfile(outDir, csvPowerName));
writetable(tableAlpha, fullfile(outDir, csvAlphaName));

save(fullfile(outDir, allDataName), 'rawData');

end
