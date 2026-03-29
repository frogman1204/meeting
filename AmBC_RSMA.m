function out_dir = AmBC_RSMA(mode_name)
%AMBC_RSMA Main script entry for RSMA-AmBC exploratory framework.
% Usage:
%   AmBC_RSMA            % defaults to 'medium'
%   AmBC_RSMA('full')

if nargin < 1
    mode_name = 'medium';
end

params = get_pack(mode_name);
out_dir = run_pack('core', params, mode_name);

fprintf('Saved folder: %s\n', out_dir);
fprintf('Exploratory figure generation complete.\n');

% NEXT STEP
% 1) full BER implementation
% 2) faster rho optimization
% 3) more accurate RSMA optimization
% 4) tag selection extension
% 5) paper-ready figure filtering
end
