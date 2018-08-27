% testsim_paired_mean_of_diff_vs_diff_of_means
% test paired mean of differences vs difference of means

n = 10;

s1 = normrnd(20,10,[n,1]);
s2 = s1 - normrnd(5,5,[n,1]);

[h_p,p_p] = ttest(s1,s2)     % paired
[h_n,p_n] = ttest2(s1,s2)    % not paired 

diff_paired = mean(s1-s2); % paired difference
diff_unpaired = mean(s1)-mean(s2); % not paired difference
% difference is the same, of course, but significance is different!

[h_diff,p_diff] = ttest(s1-s2)    % paired difference

figure;

plot(1,s1,'o'); hold on; plot(2,s2,'o');
plot([1 2],[s1 s2],'-');
colormap(jet(n));
plot(1.5,diff_paired,'ko');
plot(1.5,diff_unpaired,'kx');

set(gca,'Xlim',[0.5 2.5]);

title( sprintf('paired %.6f  not paired %.6f  paired difference %.6f',p_p,p_n,p_diff) );



