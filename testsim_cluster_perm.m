% testsim_cluster_perm
% one-sample test condition 1 vs a val

clear all;

TO_PLOT = 1;
UseBens = 1;
nperms = 500;

p_crit = 0.05;
p_threshold = 0.05;


first_cluster_length = 2;
second_cluster_length = 8;

ampl_1st_clus = 0.3;
ampl_2nd_clus = 1;

n_samples = 50;

n_trials1 = 100;
n_trials2 = 200;

t = 1:n_samples;
trial_group_1 = randn(n_samples,n_trials1) + repmat([zeros(1,10) ampl_1st_clus*ones(1,first_cluster_length) zeros(1,20) ampl_2nd_clus*ones(1,second_cluster_length) zeros(1,n_samples-10-first_cluster_length-20-second_cluster_length)]',1,n_trials1); % first dim is time, last dim is trials
trial_group_2 = randn(n_samples,n_trials2);

m1 = mean(trial_group_1,2);
m2 = mean(trial_group_2,2);
e1 = std(trial_group_1,0,2);
e2 = std(trial_group_2,0,2);



% Using permutest
[clusters, p_values, t_sums, permutation_distribution ] = ...
    permutest( trial_group_1, trial_group_2, 0, p_threshold, nperms, true);
%  permutest( trial_group_1, trial_group_2, dependent_samples, p_threshold, num_permutations, two_sided, num_clusters );


for s = 1:n_samples,
    % simple t-test
    [h(s),p(s)] = ttest2(trial_group_1(s,:),trial_group_2(s,:),'Alpha',p_crit);
end

if UseBens % Use Ben's code
   [hh,pValCont] = testsim_BenClusterPermtTest(trial_group_1',trial_group_2',nperms);
end


if TO_PLOT,
    figure;
    ig_errorband(t,m1,e1,0,'Color',[0.5 0.5 0.5]); hold on
    ig_errorband(t,m2,e2,0,'Color',[0 0 1]); hold on
    
    if sum(h) > 0,
        plot(find(h>0),0,'go'); % sample-by-sample t-test
    end
    
    if sum(p<(p_crit/n_samples))>0,
        plot(find(p<(p_crit/n_samples)),0,'ys','MarkerSize',12); % Bonf. correction
    end
    
    
    if UseBens && sum(hh)>0,
        plot(find(hh>0),0,'ro','MarkerSize',10);
    end
    
    
    for c = 1:length(clusters),
        if p_values(c) < p_crit,
            plot(clusters{c},0,'r.','MarkerSize',10);
        end
        
    end
    
    
end