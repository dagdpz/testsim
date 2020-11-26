% testsim_ttest_ttest2_correction
% testing ttest and ttest2, with and without RT baseline correction

n_subj = 10;

RT1 = normrnd(250,50,[n_subj,1]);
RT2 = RT1 + normrnd(4,1,[n_subj,1]);

[h_p,p_p] = ttest(RT1,RT2)     % paired
[h_n,p_n] = ttest2(RT1,RT2)    % not paired

c = mean([RT1 RT2],2);          % correction per subject

[h_pc,p_pc] = ttest(RT1-c,RT2-c)    % paired corrected
[h_nc,p_nc] = ttest2(RT1-c,RT2-c)    % not paired corrected 


figure;

plot(1,RT1,'o'); hold on; plot(2,RT2,'o');
colormap(jet(n_subj));
set(gca,'Xlim',[0.5 2.5]);

title( sprintf('paired %.6f  not paired %.6f  paired corr. %.6f  not paired corr. %.6f',p_p,p_n,p_pc,p_nc) );



