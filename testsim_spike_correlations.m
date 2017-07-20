function testsim_spike_correlations
N_rep = 100;

for n=1:N_rep,
	[r_per_target(n,:) r_per_hemifield(n,:) r_all(n,:)] = testsim_spike_correlations_once;

end

ig_errorbar([1 2 3 4 5 6],r_per_target,1); hold on;
ig_errorbar([7 8],r_per_hemifield,1); hold on;
ig_errorbar(9,r_all,1); hold on;


function [r_per_target r_per_hemifield r_all] = testsim_spike_correlations_once
n_trials = 100; % per target
cell1_to_cell2_factor = 0.5;

% cell 1
tuning1 = [1 1 1 5 1 1]; % first 3 left, last 3 right
noise_level1 = 1;

for k = 1:6,
	FR1(k,:) = tuning1(k) + noise_level1*randn(1,n_trials);
end

% cell 2
tuning2 = [5 5 5 5 5 5]; % first 3 left, last 3 right
noise_level2 = 1;

for k = 1:6,
	FR2(k,:) = tuning2(k) + noise_level2*randn(1,n_trials) + cell1_to_cell2_factor*(1+0.3*randn(1,n_trials)).*(FR1(k,:)-mean(FR1(k,:),2));
end

% correlations

if 0, % de-mean the conditions
	FR1 = FR1 - repmat(mean(FR1,2),1,n_trials);
	FR2 = FR2 - repmat(mean(FR2,2),1,n_trials);
end	

for k=1:6,
	r_per_target(k) = corrcoef_eval(FR1(k,:),FR2(k,:),0);
end
r_per_hemifield(1) = corrcoef_eval(reshape(FR1(1:3,:)',1,3*n_trials),reshape(FR2(1:3,:)',1,3*n_trials),0);
r_per_hemifield(2) = corrcoef_eval(reshape(FR1(4:6,:)',1,3*n_trials),reshape(FR2(4:6,:)',1,3*n_trials),0);
r_all = corrcoef_eval(reshape(FR1',1,6*n_trials),reshape(FR2',1,6*n_trials),0);
