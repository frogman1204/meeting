function save_pack(out_dir, params, all_results, tables, fig_items, summary_lines)
%SAVE_PACK Save all outputs.
% Saves:
%   - figures (.png, .fig)
%   - tables (.csv)
%   - params.mat and all_results.mat
%   - summary.txt

if ~exist(out_dir, 'dir'), mkdir(out_dir); end
for i = 1:numel(fig_items)
    saveas(fig_items{i}.fig, fullfile(out_dir, [fig_items{i}.name '.png']));
    savefig(fig_items{i}.fig, fullfile(out_dir, [fig_items{i}.name '.fig']));
end
for i = 1:numel(tables)
    writetable(tables{i}.table, fullfile(out_dir, tables{i}.name));
end
save(fullfile(out_dir, 'params.mat'), 'params');
save(fullfile(out_dir, 'all_results.mat'), 'all_results');
fid = fopen(fullfile(out_dir, 'summary.txt'), 'w');
for i = 1:numel(summary_lines), fprintf(fid, '%s\n', summary_lines{i}); end
fclose(fid);

end
