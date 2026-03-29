function ch = core_ch()
%CORE_CH Generate one Rayleigh fading channel realization.

ch.hSR1 = (randn + 1i*randn)/sqrt(2);
ch.hSR2 = (randn + 1i*randn)/sqrt(2);
ch.hSF = (randn + 1i*randn)/sqrt(2);
ch.gFR1 = (randn + 1i*randn)/sqrt(2);
ch.gFR2 = (randn + 1i*randn)/sqrt(2);

end
