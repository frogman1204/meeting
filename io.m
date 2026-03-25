function varargout = io(mode, varargin)
%IO Grouped I/O helpers: tbl, save.

switch lower(mode)
    case 'tbl'
        varargout{1} = io_tbl(varargin{:});
    case 'save'
        io_save(varargin{:});
    otherwise
        error('Unknown io mode: %s', mode);
end

end

function T = io_tbl(x, t, aS, aI, aJ, aM, aF, aX, aZ, sch)
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

function io_save(oDir, fP, fA, cP, cA, fp, fa, tp, ta, raw)
if ~exist(oDir, 'dir'); mkdir(oDir); end
saveas(fp, fullfile(oDir, [fP '.png']));
savefig(fp, fullfile(oDir, [fP '.fig']));
saveas(fa, fullfile(oDir, [fA '.png']));
savefig(fa, fullfile(oDir, [fA '.fig']));
writetable(tp, fullfile(oDir, cP));
writetable(ta, fullfile(oDir, cA));
save(fullfile(oDir, 'all_results.mat'), 'raw');
end
