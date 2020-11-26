% testsim_baseline_correction_paired_nonpaired

N_trials = 20; % number of trials
noise_trial2trial_sd = 10; % trial to trial noise, same for the baseline and response
response_mean = 1;
response_sd = 1;

b = normrnd(0,noise_trial2trial_sd,[N_trials,1]);
r = b + normrnd(response_mean,response_sd,[N_trials,1]);

if 1 % baseline correction
    b = b - b;
    r = r - b;
    
    % NOTE: baseline correction invalidates the "pairing"!
end

if 0 % absolute
    b = abs(b);
    r = abs(r);
end

plot([1 2],[b r],'ko'); hold on
plot([1 2],[b r],'k-'); hold on

[h,p] = ttest(b,r) % paired ttest
[h2,p2] = ttest2(b,r) % nonpaired ttest

% Wilcoxon signed rank test
[P,H] = signrank(b,r)
