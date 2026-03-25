function save_o(oDir, fP, fA, cP, cA, fp, fa, tp, ta, dName, raw)
%SAVE_O Save figures and outputs.

if ~exist(oDir, 'dir'); mkdir(oDir); end

saveas(fp, fullfile(oDir, [fP '.png']));
savefig(fp, fullfile(oDir, [fP '.fig']));
saveas(fa, fullfile(oDir, [fA '.png']));
savefig(fa, fullfile(oDir, [fA '.fig']));
writetable(tp, fullfile(oDir, cP));
writetable(ta, fullfile(oDir, cA));
save(fullfile(oDir, dName), 'raw');

end
