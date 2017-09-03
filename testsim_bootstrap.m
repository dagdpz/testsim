function testsim_bootstrap
% testsim_bootstrap
% bootstrap and permutation 
% https://www.cscu.cornell.edu/news/statnews/Stnews73insert.pdf !!! CI overlap != NON SIGNIFICANT DIFFERENCE
% http://courses.washington.edu/matlab1/Bootstrap_examples.html#36
% http://courses.washington.edu/matlab1/Library/bootstrap.m

N_exp = 100;

if N_exp == 1,
	TOPLOT = 1;
else
	TOPLOT = 0;
end

for k = 1:N_exp,
	
	e(k) = testsim_bootstrap_one_exp(TOPLOT);
	
end

if N_exp > 1,
	figure;
	plot([e.ci_diff]','r'); hold on
	plot([e.ci_diff_b1b2]','c:');
	
end
	

function out = testsim_bootstrap_one_exp(TOPLOT)

n_samples = 100;
n_boot = 1000;
alpha = 0.05;

m1 = 0; noise1 = 3;
m2 = 1; noise2 = 3;

x1 = m1+noise1*randn(n_samples,1);
x2 = m2+noise2*randn(n_samples,1);

fun = @(x)mean(x);

ci_type = 'percentile'; % bca is default
[ci1,bootstat1] = bootci(n_boot, {fun, x1},'type',ci_type);
[ci2,bootstat2] = bootci(n_boot, {fun, x2},'type',ci_type);

% using bootstrp instead of bootci: equals to 'percentile' method
bootstat11 =bootstrp(n_boot, fun, x1);
pct1 = 100*0.05/2;
pct2 = 100-pct1;
lower = prctile(bootstat11,pct1,1); 
upper = prctile(bootstat11,pct2,1);

ci11 =[lower;upper];

[h,p] = ttest2(x1,x2);

% now run a test on a difference between samples
% http://courses.washington.edu/matlab1/Bootstrap_examples.html#36

fun_diff = @(s1,s2) mean(s1)-mean(s2);
[ci_diff,bootstat_diff] = bootci(n_boot, {fun_diff, x1, x2},'type',ci_type);
% Hypothesis test: Does the confidence interval cover zero?
H = ci_diff(1)>0 | ci_diff(2)<0;
sampStat = fun_diff(x1,x2);

% Is bootstrap on difference same as difference of bootstats? Seems yes!
ci_diff_b1b2_l = prctile(bootstat1-bootstat2,pct1,1); 
ci_diff_b1b2_u = prctile(bootstat1-bootstat2,pct2,1);

ci_diff_b1b2 =[ci_diff_b1b2_l;ci_diff_b1b2_u];

out.h = h;
out.p = p;
out.ci1 = ci1;
out.ci2 = ci2;
out.ci11 = ci11;
out.ci_diff = ci_diff;
out.ci_diff_b1b2 =ci_diff_b1b2;

if TOPLOT,
	
figure;
subplot(1,2,1);
plot(1,mean(x1),'bo'); hold on
errorbar(1,mean(x1),std(x1)); 
plot(1,mean(bootstat1),'r.');
errorbar(1,mean(bootstat1),std(bootstat1),'r'); 
plot(1,ci1,'rs'); 
plot(1,ci11,'m*'); 

plot(2,mean(x2),'bo'); hold on
errorbar(2,mean(x2),std(x2)); 
plot(2,mean(bootstat2),'r.');
errorbar(2,mean(bootstat2),std(bootstat2),'r'); 
plot(2,ci2,'rs');

title(sprintf('n boot %d %.3f',n_boot, p));


subplot(1,2,2);
xx = min(bootstat_diff):.01:max(bootstat_diff);
hist(bootstat_diff,xx);
hold on
ylim = get(gca,'YLim');
h1=plot(sampStat*[1,1],ylim,'y-','LineWidth',2);
h2=plot(ci_diff(1)*[1,1],ylim,'r-','LineWidth',2);
plot(ci_diff(2)*[1,1],ylim,'r-','LineWidth',2);
h3=plot([0,0],ylim,'b-','LineWidth',2);
xlabel('Difference between means');

decision = {'Fail to reject H0','Reject H0'};
title(decision(H+1));
legend([h1,h2,h3],{'Sample mean',sprintf('%2.0f%% CI',100*alpha),'H0 mean'},'Location','NorthWest');


plot(ci_diff_b1b2(1)*[1,1],ylim,'c:','LineWidth',1);
plot(ci_diff_b1b2(2)*[1,1],ylim,'c:','LineWidth',1);

end

if 0
% permutation test
% https://github.com/behinger/permtest

pp = permtest(x1,x2,1000,'conservative') % approximately matches ttest2

end




