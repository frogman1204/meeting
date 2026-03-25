function [bestXi, bestZeta, bestRi, bestRj, bestSum, bestMin, bestJain] = ...
    opt_pure_noma_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList)
%OPT_PURE_NOMA_GRID Grid search xi for pure PD-NOMA (zeta=0).

[bestXi, bestZeta, bestRi, bestRj, bestSum, bestMin, bestJain] = ...
    opt_benchmark_grid(hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj, ps, alpha, noiseVar, xiList, 0);

end
