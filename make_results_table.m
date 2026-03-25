function T = make_results_table(xList, xType, avgSumRate, avgRiRate, avgRjRate, avgMaxMinRate, avgJainFairness, avgOptXi, avgOptZeta, schemeList)
%MAKE_RESULTS_TABLE Build output table for CSV export.

nX = numel(xList);
nS = numel(schemeList);

rows = nX * nS;
psCol = nan(rows, 1);
alphaCol = nan(rows, 1);
schemeCol = strings(rows, 1);

sumCol = zeros(rows, 1);
riCol = zeros(rows, 1);
rjCol = zeros(rows, 1);
minCol = zeros(rows, 1);
jainCol = zeros(rows, 1);
xiCol = zeros(rows, 1);
zetaCol = zeros(rows, 1);

k = 1;
for ix = 1:nX
    for is = 1:nS
        if strcmpi(xType, 'Ps_dBm')
            psCol(k) = xList(ix);
        else
            alphaCol(k) = xList(ix);
        end

        schemeCol(k) = string(schemeList{is});
        sumCol(k) = avgSumRate(ix, is);
        riCol(k) = avgRiRate(ix, is);
        rjCol(k) = avgRjRate(ix, is);
        minCol(k) = avgMaxMinRate(ix, is);
        jainCol(k) = avgJainFairness(ix, is);
        xiCol(k) = avgOptXi(ix, is);
        zetaCol(k) = avgOptZeta(ix, is);
        k = k + 1;
    end
end

T = table(psCol, alphaCol, schemeCol, sumCol, riCol, rjCol, minCol, jainCol, xiCol, zetaCol, ...
    'VariableNames', {'Ps_dBm', 'alpha', 'scheme_name', 'avg_sum_rate', ...
    'avg_Ri_rate', 'avg_Rj_rate', 'avg_max_min_rate', 'avg_jain_fairness', ...
    'avg_opt_xi', 'avg_opt_zeta'});

end
