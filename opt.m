function varargout = opt(mode, varargin)
%OPT Grouped optimizer helpers: opt_p, opt_b, opt_n.

switch lower(mode)
    case 'p'
        [varargout{1:7}] = opt_p(varargin{:});
    case 'b'
        [varargout{1:7}] = opt_b(varargin{:});
    case 'n'
        [varargout{1:7}] = opt_n(varargin{:});
    otherwise
        error('Unknown opt mode: %s', mode);
end

end

function [bx, bz, bri, brj, brs, brm, bfj] = opt_p(h1, h2, h3, g1, g2, ps, al, n0, xVec, zVec)
brs = -inf; bx = xVec(1); bz = zVec(1); bri = 0; brj = 0; brm = 0; bfj = 0;
for ix = 1:numel(xVec)
    for iz = 1:numel(zVec)
        xi = xVec(ix); ze = zVec(iz);
        [~, ~, ~, ri, rj, rs, rm, jf] = core('rates', h1, h2, h3, g1, g2, ps, xi, ze, al, n0);
        if rs > brs
            brs = rs; bx = xi; bz = ze; bri = ri; brj = rj; brm = rm; bfj = jf;
        end
    end
end
end

function [bx, bz, bri, brj, brs, brm, bfj] = opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, zFix)
brs = -inf; bx = xVec(1); bz = zFix; bri = 0; brj = 0; brm = 0; bfj = 0;
for ix = 1:numel(xVec)
    xi = xVec(ix);
    [~, ~, ~, ri, rj, rs, rm, jf] = core('rates', h1, h2, h3, g1, g2, ps, xi, zFix, al, n0);
    if rs > brs
        brs = rs; bx = xi; bz = zFix; bri = ri; brj = rj; brm = rm; bfj = jf;
    end
end
end

function [bx, bz, bri, brj, brs, brm, bfj] = opt_n(h1, h2, h3, g1, g2, ps, al, n0, xVec)
[bx, bz, bri, brj, brs, brm, bfj] = opt_b(h1, h2, h3, g1, g2, ps, al, n0, xVec, 0);
end
