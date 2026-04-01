function save_pack(out_dir, params, all_results, tables, fig_items, summary_lines)
%SAVE_PACK Save all outputs.
% Saves:
%   - figures (.png, .fig)
%   - tables (.csv) to out_dir and result/<yyyymmdd_HHMMSS>/
%   - params.mat and all_results.mat
%   - summary.txt

if ~exist(out_dir, 'dir'), mkdir(out_dir); end
result_csv_dir = local_build_result_dir(out_dir);
for i = 1:numel(fig_items)
    saveas(fig_items{i}.fig, fullfile(out_dir, [fig_items{i}.name '.png']));
    savefig(fig_items{i}.fig, fullfile(out_dir, [fig_items{i}.name '.fig']));
end
for i = 1:numel(tables)
    writetable(tables{i}.table, fullfile(out_dir, tables{i}.name));
    writetable(tables{i}.table, fullfile(result_csv_dir, tables{i}.name));
end
save(fullfile(out_dir, 'params.mat'), 'params');
save(fullfile(out_dir, 'all_results.mat'), 'all_results');
fid = fopen(fullfile(out_dir, 'summary.txt'), 'w');
for i = 1:numel(summary_lines), fprintf(fid, '%s\n', summary_lines{i}); end
fprintf(fid, 'csv_result_dir: %s\n', result_csv_dir);
fclose(fid);

end

function result_csv_dir = local_build_result_dir(out_dir)
% Create result/<timestamp> folder for CSV exports.
tokens = regexp(out_dir, '(\d{8}_\d{6})$', 'tokens', 'once');
if isempty(tokens)
    ts = datestr(now, 'yyyymmdd_HHMMSS');
else
    ts = tokens{1};
end
result_csv_dir = fullfile('result', ts);
if ~exist(result_csv_dir, 'dir')
    mkdir(result_csv_dir);
end
end
