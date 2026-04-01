function varargout = calc_pack(mode, varargin)
%CALC_PACK Grouped metric/table calculators.
% Inputs/outputs depend on mode:
%   'jain'  : (R1,R2) -> Jain fairness
%   'ee'    : (sum_rate,total_power) -> energy efficiency
%   'gain'  : (base,opt) -> absolute/relative gain
%   'compute_metrics_scheme' -> unified metric struct
%   'build_table_from_results' -> flattened result table

switch lower(mode)
    case 'jain'
        varargout{1} = local_jain(varargin{1}, varargin{2});
    case 'ee'
        varargout{1} = local_ee(varargin{1}, varargin{2});
    case 'gain'
        [varargout{1}, varargout{2}] = local_gain(varargin{1}, varargin{2});
    case 'compute_metrics_scheme'
        varargout{1} = local_metrics(varargin{:});
    case 'build_table_from_results'
        varargout{1} = local_table(varargin{1});
    otherwise
        error('Unknown calc mode: %s', mode);
end

end

function j = local_jain(R1, R2)
den = 2*(R1^2 + R2^2);
if den == 0, j = 0; else, j = (R1+R2)^2/den; end
end

function ee = local_ee(sum_rate, total_power)
if total_power <= 0, ee = 0; else, ee = sum_rate/total_power; end
end

function [gain_abs, gain_rel] = local_gain(base_vec, opt_vec)
gain_abs = opt_vec - base_vec;
gain_rel = 100 * gain_abs ./ max(abs(base_vec), 1e-9);
end

function met = local_metrics(R1, R2, total_power, rho_used, rho_opt, rate_threshold)
met.R1 = R1;
met.R2 = R2;
met.sum_rate = R1 + R2;
met.max_min_rate = min(R1, R2);
met.jain_fairness = local_jain(R1, R2);
met.energy_efficiency = local_ee(met.sum_rate, total_power);
met.rho_used = rho_used;
met.rho_opt = rho_opt;
met.ber_tag = NaN; met.ber_user1 = NaN; met.ber_user2 = NaN; % TODO: BER
met.outage_flag = (met.max_min_rate < rate_threshold);
end

function T = local_table(res)
nx = numel(res.x_values); ns = numel(res.scheme_names); rows = nx*ns;
x = zeros(rows,1); scheme = strings(rows,1);
vals = {'R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'};
out = zeros(rows, numel(vals));
k = 1;
for ix=1:nx
 for is=1:ns
  x(k)=res.x_values(ix); scheme(k)=string(res.scheme_names{is});
  for iv=1:numel(vals), out(k,iv)=res.(vals{iv})(ix,is); end
  k=k+1;
 end
end
T = table(x, scheme, out(:,1), out(:,2), out(:,3), out(:,4), out(:,5), out(:,6), out(:,7), out(:,8), out(:,9), out(:,10), out(:,11), out(:,12), ...
 'VariableNames', {'x_value','scheme_name','R1','R2','sum_rate','max_min_rate','jain_fairness','energy_efficiency','rho_used','rho_opt','ber_tag','ber_user1','ber_user2','outage_flag'});
end
