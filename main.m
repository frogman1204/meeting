% MAIN Single entry script to run the framework (not a function).
% Usage:
%   - Run this file directly.
%   - Edit mode_name below to 'medium' or 'full'.

mode_name = 'medium';  % change to 'full' when needed

out_dir = run(mode_name);
fprintf('Saved folder: %s\n', out_dir);
fprintf('Exploratory figure generation complete.\n');

% NEXT STEP
% 1) full BER implementation
% 2) faster rho optimization
% 3) more accurate RSMA optimization
% 4) tag selection extension
% 5) paper-ready figure filtering
