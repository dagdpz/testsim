% testing ttest and ttest2, with and without RT baseline correction

n_subj = 20;

c0 = normrnd(0,50,[n_subj,1]); % condition 0
c1 = c0 - normrnd(10,2,[n_subj,1]); % condition 1

[h,p] = ttest(c0,c1) % paired ttest
[h,p] = ttest(c0-c1) % non-paired differential against 0



