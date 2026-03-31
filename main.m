% MAIN Single entry script to run the framework (not a function).
% Quick options:
%   out_dir = run('research_rsma');      % NOMA+RSMA research workflow
%   out_dir = run('paper_reproduction'); % paper-style NOMA/OMA baselines

mode_name = 'research_rsma';  % change to 'paper_reproduction' when needed

out_dir = run(mode_name);
fprintf('Saved folder: %s\n', out_dir);
fprintf('Exploratory figure generation complete.\n');
