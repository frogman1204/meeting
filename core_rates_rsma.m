function [R1, R2, out] = core_rates_rsma(ch, Ps, sic_err, sigma2, rho)
%CORE_RATES_RSMA 2-user RSMA rate calculation with AmBC effective channels.
% RSMA transmit signal model:
%   x = sqrt(Pc)*sc + sqrt(P1)*s1 + sqrt(P2)*s2
% with strict power constraint:
%   Pc + P1 + P2 = Ps

% Stable split ratios for exploratory version.
alpha_c = 0.20;  % common-stream fraction
alpha_1 = 0.40;  % private-stream-1 fraction
alpha_2 = 1 - alpha_c - alpha_1; % private-stream-2 fraction

Pc = Ps * alpha_c;
P1 = Ps * alpha_1;
P2 = Ps * alpha_2;

% Enforce Pc + P1 + P2 = Ps exactly (numerically stable).
sumP = Pc + P1 + P2;
if sumP > 0
    scale = Ps / sumP;
    Pc = Pc * scale;
    P1 = P1 * scale;
    P2 = P2 * scale;
end

% AmBC effective channel gain: direct + backscatter link contribution.
g1 = abs(ch.hSR1)^2 + rho * abs(ch.hSF)^2 * abs(ch.gFR1)^2;
g2 = abs(ch.hSR2)^2 + rho * abs(ch.hSF)^2 * abs(ch.gFR2)^2;

% Common-stream decoding SINR at each user.
sinr_c1 = Pc * g1 / (P1 * g1 + P2 * g1 + sigma2);
sinr_c2 = Pc * g2 / (P1 * g2 + P2 * g2 + sigma2);
Rc_u1 = log2(1 + sinr_c1);
Rc_u2 = log2(1 + sinr_c2);
Rc = min(Rc_u1, Rc_u2);

% Private-stream decoding SINR (simple imperfect SIC model).
sinr_p1 = P1 * g1 / (P2 * g1 * sic_err + sigma2);
sinr_p2 = P2 * g2 / (P1 * g2 + sigma2);

% Common-rate split between users (C1 + C2 = Rc).
mu = 0.5;
C1 = mu * Rc;
C2 = (1 - mu) * Rc;

R1 = C1 + log2(1 + sinr_p1);
R2 = C2 + log2(1 + sinr_p2);

% Return detailed RSMA quantities for analysis/debugging.
out.sinr_common_u1 = sinr_c1;
out.sinr_common_u2 = sinr_c2;
out.sinr_private_u1 = sinr_p1;
out.sinr_private_u2 = sinr_p2;
out.common_rate_u1 = Rc_u1;
out.common_rate_u2 = Rc_u2;
out.common_rate = Rc;
out.C1 = C1;
out.C2 = C2;
out.Pc = Pc;
out.P1 = P1;
out.P2 = P2;
out.g1 = g1;
out.g2 = g2;

end
