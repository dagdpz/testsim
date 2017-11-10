function testsim_chance_performance
% let's assume that n_subj subjects did n_trials trials on a binay choice task, is the performance at chance?
% see also testsim_binomial_prob

n_experiments = 30;


random_prob_of_success = 0.5;
n_subj		= 44;
n_trials	= 160;
n_boot		= 1000;
alphaValue	= 0.05;

for e = 1:n_experiments,
	for n = 1:n_subj,
		n_success(n)	= sum(randn(1,n_trials)>0);
		perf(n)		= n_success(n)/n_trials; % performance for random outcomes
		p_binom(n)	= myBinomTest(n_success(n),n_trials,random_prob_of_success,'two'); % part of Igtools/external
	end
	
	for n = 1:n_boot, %
		n_success_(n)	= sum(randn(1,n_trials)>0);
		perf_(n)	= n_success_(n)/n_trials; % performance for random outcomes
	end
	
	if 1
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
	xlabel('Peformance');
	
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
	xlabel('Probability');
	
	end % if plot
	
	% test if this experiment falls into expected binomial proportions
	[nullHypothesis(e), falloutIndex{e}] = test_binomial_proportions(n_trials*ones(n_subj,1), n_success, random_prob_of_success, 0.05, true);
	if ~isempty(falloutIndex{e}),
		fallout(e).index = perf(falloutIndex{e});
	else
		fallout(e).index = NaN;
	end
	
end
figure;
plot(1:e,1-nullHypothesis,'k-s'); hold on;
for e = 1:n_experiments,
	plot(e,fallout(e).index,'ro');
end
set(gca,'Ylim',[0 1]);
xlabel('Experiment');
ylabel('Reject null hypothesis');



