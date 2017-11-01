function testsim_chance_performance
% let's assume that n_subj subjects did n_trials trials on a binay choice task, is the performance at chance?
% see also testsim_binomial_prob

Z = (p1 - p2)/(sqrt(((p1+p2)/2)* (1-(p1+p2)/2)*(2/160)) = (0.503-0.5)/sqrt(((0.5+0.503)/2)*(1-(0.5+0.503)/2)*2/160)

random_prob_of_success = 0.5;
n_subj		= 45;
n_trials	= 160;
n_boot		= 10000;

for n = 1:n_subj,
	n_success(n)	= sum(randn(1,n_trials)>0);
	perf(n)		= n_success(n)/n_trials; % performance for random outcomes
	p_binom(n)	= myBinomTest(n_success(n),n_trials,random_prob_of_success,'one'); % part of Igtools/external
end

for n = 1:n_boot, % 
	n_success_(n)	= sum(randn(1,n_trials)>0);
	perf_(n)	= n_success_(n)/n_trials; % performance for random outcomes
end

figure;
perf_bins = [0.0125:0.025:1-0.0125];
subplot(2,1,1)
h_perf = hist(perf,perf_bins);
h_perf_ = hist(perf_,perf_bins);
bar(perf_bins,hist2per(h_perf)); hold on;
plot(perf_bins,hist2per(h_perf_));
ylim1 = get(gca,'Ylim');
line([mean(perf_) mean(perf_)],[0 ylim1(2)],'Color',[0 1 0]);

title(sprintf('%d subj: mean %.3f std %.3f sem %.3f range [%.3f - %.3f]',n_subj, mean(perf), std(perf), std(perf)/sqrt(length(perf)), min(perf), max(perf) ) );

% now estimate CI via "bootstraping": e.g. for 160 trials and n_boot = 100000, ci = [0.4250 0.5750]
pct1 = 100*0.05/2;
pct2 = 100-pct1;
lower = prctile(perf_',pct1,1); 
upper = prctile(perf_',pct2,1);
ci =[lower;upper]; 

line([ci(1) ci(1)],[0 ylim1(2)],'Color',[1 0 0]);
line([ci(2) ci(2)],[0 ylim1(2)],'Color',[1 0 0]);

subplot(2,1,2)
hc_p_binom = histc(p_binom,[0:0.025:1]);
bar([0:0.025:1]+0.025/2,hc_p_binom); hold on;
set(gca,'Xlim',[0 1]);
ylim2 = get(gca,'Ylim');
line([0.05 0.05],[0 ylim2(2)],'Color',[1 0 0]);




