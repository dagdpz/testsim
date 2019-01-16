function testsim_bootstrap
% testsim_bootstrap
% bootstrap and permutation 
% https://www.cscu.cornell.edu/news/statnews/Stnews73insert.pdf !!! CI overlap != NON SIGNIFICANT DIFFERENCE
% http://courses.washington.edu/matlab1/Bootstrap_examples.html#36
% http://courses.washington.edu/matlab1/Library/bootstrap.m

N_exp = 100;

if N_exp < 5,
	TOPLOT = 1;
else
	TOPLOT = 0;
end


data.n_samples = 100;
data.n_boot = 1000;
data.alpha = 0.05;

m1 = 0; noise1 = 3;
m2 = 1; noise2 = 3;

data.x1 = m1+noise1*randn(data.n_samples,1);
data.x2 = m2+noise2*randn(data.n_samples,1);


for k = 1:N_exp,
	
	e(k) = testsim_bootstrap_one_exp(TOPLOT,data); % use the same data for multiple experiments
	% e(k) = testsim_bootstrap_one_exp(TOPLOT); % use newly generated data for each experiment
	
end

if N_exp > 1,
	figure;
	plot([e.ci_diff]','r'); hold on
	plot([e.ci_diff_b1b2]','c:');
	plot([e.H]','k-o');
	if ~isempty(e(1).H_iter), plot([e.H_iter]','m-x'); end;
	xlabel('number of exp.');
	title(sprintf('%d samples, %d boots',e(1).n_samples, e(1).n_boot));
	legend({'pre','post','sig. diff'})
end
	

function out = testsim_bootstrap_one_exp(TOPLOT, data)

if nargin < 2,
n_samples = 100;
n_boot = 1000;
alpha = 0.05;

m1 = 0; noise1 = 3;
m2 = 1; noise2 = 3;

x1 = m1+noise1*randn(n_samples,1);
x2 = m2+noise2*randn(n_samples,1);

% outliers
% x1(1) = 0;
% x2(1) = 100;

else % use the same data for multiple experiments
n_samples	= data.n_samples;
n_boot		= data.n_boot;
alpha		= data.alpha;

x1		= data.x1;
x2		= data.x2;

end

fun = @(x)mean(x);

ci_type = 'percentile'; % bca is default
[ci1,bootstat1] = bootci(n_boot, {fun, x1},'alpha',alpha,'type',ci_type);
[ci2,bootstat2] = bootci(n_boot, {fun, x2},'alpha',alpha,'type',ci_type);

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
[ci_diff,bootstat_diff] = bootci(n_boot, {fun_diff, x1, x2},'alpha',alpha,'type',ci_type);
% Hypothesis test: Does the confidence interval cover zero?
H = ci_diff(1)>0 | ci_diff(2)<0;
sampStat = fun_diff(x1,x2);

% Is bootstrap on difference same as difference of bootstats? Seems yes!
ci_diff_b1b2_l = prctile(bootstat1-bootstat2,pct1,1); 
ci_diff_b1b2_u = prctile(bootstat1-bootstat2,pct2,1);

ci_diff_b1b2 =[ci_diff_b1b2_l;ci_diff_b1b2_u];


% now try jackknife - not good for CI estimation
pct1 = 100*alpha/2;
pct2 = 100-pct1;

jackstat_diff = jackknife(fun_diff,x1,x2);
ci_diff_prctile_jack = prctile(jackstat_diff,[pct1 pct2]);
H_jack = ci_diff_prctile_jack(1)>0 | ci_diff_prctile_jack(2)<0;

out.n_samples	= n_samples;
out.n_boot	= n_boot;
out.h		= h;
out.p		= p;
out.ci1		= ci1;
out.ci2		= ci2;
out.ci11		= ci11;
out.ci_diff		= ci_diff;
out.ci_diff_b1b2	= ci_diff_b1b2;
out.H			= H;

ci_diff_iter		= [];
H_iter			= [];
if 0, % try iterated bootstrap
	[ci_diff_iter,bootstat_diff_iter] = ibootci([2000 200], {fun_diff, x1, x2},'alpha',alpha);
	H_iter = ci_diff_iter(1)>0 | ci_diff_iter(2)<0;

end

out.ci_diff_iter	= ci_diff_iter;
out.H_iter		= H_iter;


if TOPLOT,
	
figure('Position',[200 200 900 400]);
subplot(1,3,1);

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


subplot(1,3,2);
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
legend([h1,h2,h3],{'mean diff',sprintf('%2.0f%% CI',100*alpha),'0'},'Location','NorthWest');

plot(ci_diff_b1b2(1)*[1,1],ylim,'c:','LineWidth',1);
plot(ci_diff_b1b2(2)*[1,1],ylim,'c:','LineWidth',1);

if ~isempty(ci_diff_iter)
	plot(ci_diff_iter(1)*[1,1],ylim,'m:','LineWidth',1);
	plot(ci_diff_iter(2)*[1,1],ylim,'m:','LineWidth',1);
end


subplot(1,3,3);
xx = min(jackstat_diff):.01:max(jackstat_diff);
hist(jackstat_diff,xx);
hold on
ylim = get(gca,'YLim');
h1=plot(mean(jackstat_diff)*[1,1],ylim,'y-','LineWidth',2);
h2=plot(ci_diff_prctile_jack(1)*[1,1],ylim,'r-','LineWidth',2);
plot(ci_diff_prctile_jack(2)*[1,1],ylim,'r-','LineWidth',2);
h3=plot([0,0],ylim,'b-','LineWidth',2);
xlabel('Difference between means');

decision = {'Fail to reject H0','Reject H0'};
title(decision(H_jack+1));
legend([h1,h2,h3],{'mean jackknife',sprintf('%2.0f%% CI',100*alpha),'0'},'Location','NorthWest');




end

if 0
% permutation test
% https://github.com/behinger/permtest

pp = permtest(x1,x2,1000,'conservative') % approximately matches ttest2

end


