function res = run_sweep_tags(p)
%RUN_SWEEP_TAGS Stub for tag-count sweep.

nx = numel(p.tag_count_vec);
ns = numel(p.scheme_names);
res.x_values = p.tag_count_vec;
res.scheme_names = p.scheme_names;
res.sweep_name = 'tags';
res.x_label = 'Tag count';

fields = {'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
for i = 1:numel(fields)
    res.(fields{i}) = nan(nx, ns);
end

end
