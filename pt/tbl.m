function T = tbl(x, t, aS, aI, aJ, aM, aF, aX, aZ, sch)
%TBL Build CSV table.

nX = numel(x); nS = numel(sch); nR = nX*nS;
pCol = nan(nR,1); aCol = nan(nR,1); sCol = strings(nR,1);
S = zeros(nR,1); I = zeros(nR,1); J = zeros(nR,1); M = zeros(nR,1); F = zeros(nR,1); X = zeros(nR,1); Z = zeros(nR,1);

k = 1;
for ix = 1:nX
    for is = 1:nS
        if strcmpi(t, 'Ps_dBm'); pCol(k) = x(ix); else; aCol(k) = x(ix); end
        sCol(k) = string(sch{is});
        S(k)=aS(ix,is); I(k)=aI(ix,is); J(k)=aJ(ix,is); M(k)=aM(ix,is); F(k)=aF(ix,is); X(k)=aX(ix,is); Z(k)=aZ(ix,is);
        k = k + 1;
    end
end

T = table(pCol, aCol, sCol, S, I, J, M, F, X, Z, 'VariableNames', ...
    {'Ps_dBm','alpha','scheme_name','avg_sum_rate','avg_Ri_rate','avg_Rj_rate','avg_max_min_rate','avg_jain_fairness','avg_opt_xi','avg_opt_zeta'});

end
