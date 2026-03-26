function [gain_abs, gain_rel] = calc_gain(base_vec, opt_vec)
%CALC_GAIN Absolute and relative gain.

gain_abs = opt_vec - base_vec;
gain_rel = 100 * gain_abs ./ max(abs(base_vec), 1e-9);

end
