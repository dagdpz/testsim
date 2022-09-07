% testsim_cluster_perm
TO_PLOT = 1;
UseBens = 0;

p_crit = 0.05;
p_threshold = 0.05;

n_samples = 50;
n_trials1 = 100;
n_trials2 = 70;

t = 1:n_samples;
trial_group_1 = randn(n_samples,n_trials1) + 1*repmat([zeros(1,10) 0.5*ones(1,10) zeros(1,20) ones(1,10)]',1,n_trials1); % first dim is time, last dim is trials
trial_group_2 = randn(n_samples,n_trials2);

m1 = mean(trial_group_1,2);
m2 = mean(trial_group_2,2);
e1 = std(trial_group_1,0,2);
e2 = std(trial_group_2,0,2);





% Using permutest
[clusters, p_values, t_sums, permutation_distribution ] = ...
    permutest( trial_group_1, trial_group_2, 0, p_threshold, 100, true);
%  permutest( trial_group_1, trial_group_2, dependent_samples, p_threshold, num_permutations, two_sided, num_clusters );


for s = 1:n_samples,
% simple t-test
    [h(s),p(s)] = ttest2(trial_group_1(s,:),trial_group_2(s,:));
end

if UseBens % Use Ben's code
   [hh,pValCont] = ClusterPermtTest(trial_group_1',trial_group_2');
end


if TO_PLOT,
    figure;
    ig_errorband(t,m1,e1,0,'Color',[0.5 0.5 0.5]); hold on
    ig_errorband(t,m2,e2,0,'Color',[0 0 1]); hold on
    
    plot(find(h>0),0,'go');
    if UseBens,
        plot(find(hh>0),0,'ro','MarkerSize',10);
    end
    
    
    for c = 1:length(clusters),
        if p_values(c) < p_crit,
            plot(clusters{c},0,'r.','MarkerSize',10);
        end
        
    end
    
    
    
end