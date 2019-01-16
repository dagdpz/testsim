function testsim_bootstrap_fano
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

data.n_trials	= 100;
data.n_boot	= 1000;
data.alpha	= 0.05;

% counts
data.c1	= poissrnd(10,1,data.n_trials)';	% pre: Poisson 
data.c2	= poissrnd(20,1,data.n_trials)'+10;	% pos: add constant amount of spikes to quench variability



for k = 1:N_exp,
	
	% e(k) = testsim_bootstrap_fano_one_exp(TOPLOT); % for each exp., generate new data
	e(k) = testsim_bootstrap_fano_one_exp(TOPLOT,data); % use the same data
	
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
	

function out = testsim_bootstrap_fano_one_exp(TOPLOT,data)

if nargin < 2, % simulate data (each experiment, new data)

n_trials	= 100;
n_boot		= 1000;
alpha		= 0.05;

pre_rate	= 10;
pos_rate	= 20;

% counts
c1	= poissrnd(pre_rate,1,n_trials)';	% pre: Poisson 
c2	= poissrnd(pos_rate,1,n_trials)'+0;	% pos: add constant amount of spikes to quench variability

else
n_trials	= data.n_trials;
n_boot		= data.n_boot;
alpha		= data.alpha;

% counts
c1	=	data.c1; 
c2	=	data.c2; 
	
end

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

% is ci_diff just percentiles of bootstat_diff? YES, if we use ci_type = 'percentile';
pct1 = 100*alpha/2;
pct2 = 100-pct1;
ci_diff_prctile = prctile(bootstat_diff,[pct1 pct2]);

out.n_trials	= n_trials;
out.n_boot	= n_boot;
out.ff_pre	= ff_pre;
out.ff_pos	= ff_pos;
out.ci1		= ci1;
out.ci2		= ci2;
out.ci_diff	= ci_diff;
out.H		= H;

% now try jackknife - not good for CI estimation
jackstat_diff = jackknife(fun_diff,c1,c2);
ci_diff_prctile_jack = prctile(jackstat_diff,[pct1 pct2]);
H_jack = ci_diff_prctile_jack(1)>0 | ci_diff_prctile_jack(2)<0;


% do manual jackknife just to be sure that jackknife works this way - YES, IT DOES...
for tr = 1:n_trials,
	i_take=setdiff((1:n_trials),tr); % drop 1 trial
	jackstat_diff_manu(tr) = fun_diff(c1(i_take),c2(i_take));
end




if TOPLOT,
	
figure('Position',[200 200 900 400]);
subplot(1,3,1);
plot(1,var(c1)/mean(c1),'bo'); hold on
plot(1,mean(bootstat1),'r.');
errorbar(1,mean(bootstat1),std(bootstat1),'r'); 
plot(1,ci1,'rs'); 

plot(2,var(c2)/mean(c2),'bo'); hold on
plot(2,mean(bootstat2),'r.');
errorbar(2,mean(bootstat2),std(bootstat2),'r'); 
plot(2,ci2,'rs');


subplot(1,3,2);
xx = min(bootstat_diff):.01:max(bootstat_diff);
hist(bootstat_diff,xx);
hold on
ylim = get(gca,'YLim');
h1=plot(sampStat*[1,1],ylim,'y-','LineWidth',2);
h2=plot(ci_diff(1)*[1,1],ylim,'r-','LineWidth',2);
plot(ci_diff(2)*[1,1],ylim,'r-','LineWidth',2);
h3=plot([0,0],ylim,'b-','LineWidth',2);
xlabel('bootstat diff');

decision = {'Fail to reject H0','Reject H0'};
title(decision(H+1));
legend([h1,h2,h3],{'mean diff',sprintf('%2.0f%% CI',100*alpha),'0'},'Location','NorthWest');


subplot(1,3,3);
xx = min(jackstat_diff):.01:max(jackstat_diff);
hist(jackstat_diff,xx);
hold on
ylim = get(gca,'YLim');
h1=plot(mean(jackstat_diff)*[1,1],ylim,'y-','LineWidth',2);
h2=plot(ci_diff_prctile_jack(1)*[1,1],ylim,'r-','LineWidth',2);
plot(ci_diff_prctile_jack(2)*[1,1],ylim,'r-','LineWidth',2);
h3=plot([0,0],ylim,'b-','LineWidth',2);
xlabel('jackstat diff');

decision = {'Jackknife: Fail to reject H0','Jackknife: Reject H0'};
title(decision(H_jack+1));
legend([h1,h2,h3],{'mean diff jackknife',sprintf('%2.0f%% CI',100*alpha),'0'},'Location','NorthWest');


end

if 0
% permutation test
% https://github.com/behinger/permtest

pp = permtest(x1,x2,1000,'conservative') % approximately matches ttest2

end




