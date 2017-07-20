% linus choice ttest examples

load testsim_ttestlinus_choice_example

[h,p] = ttest2(data(:,1),data(:,7))
[h,p] = ttest(data(:,1),data(:,7))

[H,P,SIGPAIRS] = ttest_bonf([data(:,1) data(:,7)])
[H,P,SIGPAIRS] = ttest_bonf(data,[1 2; 1 3; 1 4; 1 5; 1 6; 1 7; 1 8])

[p,anovatab,stats] = anova1(data)
dunnett(stats,[2 3 4 5 6 7 8],[1])

holm([data_t data_t_group'],1)
