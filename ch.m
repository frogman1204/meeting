function [h1, h2, h3, g1, g2] = ch()
%CH One Rayleigh channel realization.

h1 = (randn + 1i*randn)/sqrt(2);
h2 = (randn + 1i*randn)/sqrt(2);
h3 = (randn + 1i*randn)/sqrt(2);
g1 = (randn + 1i*randn)/sqrt(2);
g2 = (randn + 1i*randn)/sqrt(2);

end
