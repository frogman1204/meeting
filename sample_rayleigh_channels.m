function [hS_Ri, hS_Rj, hS_F, gF_Ri, gF_Rj] = sample_rayleigh_channels()
%SAMPLE_RAYLEIGH_CHANNELS Sample one independent Rayleigh channel realization.

hS_Ri = (randn + 1i*randn)/sqrt(2);
hS_Rj = (randn + 1i*randn)/sqrt(2);
hS_F = (randn + 1i*randn)/sqrt(2);
gF_Ri = (randn + 1i*randn)/sqrt(2);
gF_Rj = (randn + 1i*randn)/sqrt(2);

end
