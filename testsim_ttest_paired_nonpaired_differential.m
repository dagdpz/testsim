% testsim_ttest_paired_nonpaired_differential

n_subj = 20; % number of subjects or trials

c0 = normrnd(0,50,[n_subj,1]); % condition 0
c1 = c0 + normrnd(0,2,[n_subj,1]); % condition 1

[h,p] = ttest(c0,c1) % paired ttest
[h,p] = ttest(c0-c1) % non-paired differential against 0

% Wilcoxon signed rank test
[P,H] = signrank(c0,c1)
