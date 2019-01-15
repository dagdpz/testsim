function testsim_bootstrap_fano
% testsim_bootstrap
% bootstrap and permutation 
% https://www.cscu.cornell.edu/news/statnews/Stnews73insert.pdf !!! CI overlap != NON SIGNIFICANT DIFFERENCE
% http://courses.washington.edu/matlab1/Bootstrap_examples.html#36
% http://courses.washington.edu/matlab1/Library/bootstrap.m


N_exp = 1;

if N_exp == 1,
	TOPLOT = 1;
else
	TOPLOT = 0;
end

for k = 1:N_exp,
	
	e(k) = testsim_bootstrap_fano_one_exp(TOPLOT);
	
end

if N_exp > 1,
	figure;
	plot([e.ff_pre]','b'); hold on
	plot([e.ff_pos]','r');
	plot([e.H]','k-o');
	xlabel('number of exp.');
	title(sprintf('%d trials, %d boots',e(1).n_trials, e(1).n_boot));
	legend({'pre','post','sig. diff'})
	
end
	

function out = testsim_bootstrap_fano_one_exp(TOPLOT)

n_trials	= 1000;
n_boot		= 1000;
alpha		= 0.05;

pre_rate	= 10;
pos_rate	= 20;

% counts
c1	= poissrnd(pre_rate,1,n_trials)';	% pre: Poisson 
c2	= poissrnd(pos_rate,1,n_trials)'+5;	% pos: add constant amount of spikes to quench variability

% FF for all trials
ff_pre	= var(c1)/mean(c1);
ff_pos	= var(c2)/mean(c2);


fun = @(x)var(x)/mean(x);

ci_type = 'percentile'; % bca is default
[ci1,bootstat1] = bootci(n_boot, {fun, c1},'alpha',alpha,'type',ci_type);
[ci2,bootstat2] = bootci(n_boot, {fun, c2},'alpha',alpha,'type',ci_type);
 

% now run a test on a difference between pre and post FF

fun_diff = @(x1,x2) var(x1)/mean(x1)-var(x2)/mean(x2);
[ci_diff,bootstat_diff] = bootci(n_boot, {fun_diff, c1, c2},'alpha',alpha,'type',ci_type);
% Hypothesis test: Does the confidence interval cover zero?
H = ci_diff(1)>0 | ci_diff(2)<0;
sampStat = fun_diff(c1,c2);

out.n_trials	= n_trials;
out.n_boot	= n_boot;
out.ff_pre	= ff_pre;
out.ff_pos	= ff_pos;
out.ci1		= ci1;
out.ci2		= ci2;
out.ci_diff	= ci_diff;
out.H		= H;



if TOPLOT,
	
figure;
subplot(1,2,1);
plot(1,var(c1)/mean(c1),'bo'); hold on
plot(1,mean(bootstat1),'r.');
errorbar(1,mean(bootstat1),std(bootstat1),'r'); 
plot(1,ci1,'rs'); 

plot(2,var(c2)/mean(c2),'bo'); hold on
plot(2,mean(bootstat2),'r.');
errorbar(2,mean(bootstat2),std(bootstat2),'r'); 
plot(2,ci2,'rs');


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
legend([h1,h2,h3],{'Sample mean',sprintf('%2.0f%% CI',100*alpha),'0'},'Location','NorthWest');


end

if 0
% permutation test
% https://github.com/behinger/permtest

pp = permtest(x1,x2,1000,'conservative') % approximately matches ttest2

end




