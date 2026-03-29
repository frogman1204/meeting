function out_dir = main(mode_name)
%MAIN Single entry script to run the framework.
% Usage:
%   main            % default medium mode
%   main('full')

if nargin < 1
    mode_name = 'medium';
end

out_dir = run(mode_name);
fprintf('Saved folder: %s\n', out_dir);
fprintf('Exploratory figure generation complete.\n');

% NEXT STEP
% 1) full BER implementation
% 2) faster rho optimization
% 3) more accurate RSMA optimization
% 4) tag selection extension
% 5) paper-ready figure filtering
end
