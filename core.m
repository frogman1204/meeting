function varargout = core(mode, varargin)
%CORE Grouped core helpers: ch, p2w, rates.

switch lower(mode)
    case 'ch'
        [varargout{1:5}] = core_ch();
    case 'p2w'
        varargout{1} = core_p2w(varargin{1});
    case 'rates'
        [varargout{1:8}] = core_rates(varargin{:});
    otherwise
        error('Unknown core mode: %s', mode);
end

end

function [h1, h2, h3, g1, g2] = core_ch()
h1 = (randn + 1i*randn)/sqrt(2);
h2 = (randn + 1i*randn)/sqrt(2);
h3 = (randn + 1i*randn)/sqrt(2);
g1 = (randn + 1i*randn)/sqrt(2);
g2 = (randn + 1i*randn)/sqrt(2);
end

function pw = core_p2w(pd)
pw = 10.^((pd - 30)./10);
end

function [sij, sii, sjj, ri, rj, rs, rmin, jf] = core_rates(h1, h2, h3, g1, g2, ps, xi, ze, al, n0)
t1 = abs(h1)^2 + ze*abs(h3)^2*abs(g1)^2;
t2 = abs(h2)^2 + ze*abs(h3)^2*abs(g2)^2;

sij = ps*(1-xi)*t1 / (ps*xi*t1 + n0);
sii = ps*xi*t1 / (abs(h1)^2 * ps*(1-xi)*al + n0);
sjj = ps*(1-xi)*t2 / (ps*xi*t2 + n0);

ri = log2(1 + sii);
rj = log2(1 + sjj);
rs = ri + rj;
rmin = min(ri, rj);
jf = (rs^2) / (2*(ri^2 + rj^2));
end
