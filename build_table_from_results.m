function T = build_table_from_results(res)
%BUILD_TABLE_FROM_RESULTS Flatten one sweep result into a table.

nx = numel(res.x_values);
ns = numel(res.scheme_names);
rows = nx*ns;

x = zeros(rows,1);
scheme = strings(rows,1);
vals = {'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
out = zeros(rows, numel(vals));

k=1;
for ix=1:nx
    for is=1:ns
        x(k)=res.x_values(ix);
        scheme(k)=string(res.scheme_names{is});
        for iv=1:numel(vals)
            out(k,iv)=res.(vals{iv})(ix,is);
        end
        k=k+1;
    end
end

T = table(x, scheme, out(:,1), out(:,2), out(:,3), out(:,4), out(:,5), out(:,6), out(:,7), out(:,8), out(:,9), out(:,10), out(:,11), out(:,12), ...
    'VariableNames', {'x_value','scheme_name','R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'});

end
