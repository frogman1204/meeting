function chan = sample_rayleigh_channels()
%SAMPLE_RAYLEIGH_CHANNELS Sample one independent Rayleigh channel realization.

chan.hS_Ri = (randn + 1i*randn)/sqrt(2);
chan.hS_Rj = (randn + 1i*randn)/sqrt(2);
chan.hS_F = (randn + 1i*randn)/sqrt(2);
chan.gF_Ri = (randn + 1i*randn)/sqrt(2);
chan.gF_Rj = (randn + 1i*randn)/sqrt(2);

end
