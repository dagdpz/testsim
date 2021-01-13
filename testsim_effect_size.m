% function testsim_effect_size
% compare different effect size measures
%
% https://www.discoveringstatistics.com/repository/effectsizes.pdf
% https://imaging.mrc-cbu.cam.ac.uk/statswiki/FAQ/nonpz
% http://core.ecu.edu/psyc/wuenschk/docs30/Nonparametric-EffectSize.pdf
% https://www.psychometrica.de/effect_size.html
% 
% https://www.researchgate.net/post/How-to-interpret-the-effect-sizes-by-Rosenthal-1991
% Some effect size statistics are signed (e.g. r, phi, Cohen's d, Cliff's delta) and some are not (e.g. Vargha and Delaney's A, Cramer's V). 
% For signed effect sizes, a negative value usually means that the second group is larger than the first, or with phi that the association is negative. 
% A lot of caution is needed here, though. One issue is that software may change the order of your groups. 
% Another is that some software may report the absolute value of the effect size statistic. It's best to always check manually, e.g. compare the means of the two groups.
% There's some discussion at the following link about the effect size for the signed rank test, particularly about using an r value, where r = Z / sqrt(N). 
% https://www.researchgate.net/post/How_can_I_calculate_the_effect_size_for_Wilcoxon_signed_rank_test
%
% note: for unequal sample sizes (n_trials), computeCohen_d is Hedges' g
% http://www.socscistatistics.com/effectsize/Default3.aspx
% 
% this function uses computeCohen_d from Igtools/external


% variant 1: one task, two conditions (e.g. pre- and post-injection)

% condition 1
n_trials1 = 10;
mean1 = 1;
sd1 = 1;


% condition 2
n_trials2 = 8;
mean2 = 0;
sd2 = 1;

s1 = mean1 + sd1*randn(1,n_trials1);
s2 = mean2 + sd2*randn(1,n_trials2);

[ht pt ctt statt] = ttest2(s1,s2);
[pw,hw,statsw] = ranksum(s1,s2); % Wilcoxon rank sum test, unpaired (independent samples) (aka Mann–Whitney U test)

d = computeCohen_d(s1, s2);
r = norminv(pw)/sqrt(n_trials1+n_trials2);

rr = corrcoef([s1 s2],[ones(1,n_trials1) zeros(1,n_trials2)]);

disp(sprintf('pt = %.3f, pw = %.3f, Cohen d = %.3f, Rosenthal r = %.3f, cc = %.3f',pt,pw,d,r,rr(1,2)));
