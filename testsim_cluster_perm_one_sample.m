% testsim_cluster_perm_one_sample
% one-sample test condition 1 vs a fixed value

% clear all;

TO_PLOT = 1;
nperms = 500;

p_crit = 0.05;
p_threshold = 0.05;


first_cluster_length = 2;
second_cluster_length = 8;

ampl_1st_clus = 0.5;
ampl_2nd_clus = 0.5;

fixed_value = 0.5;

n_samples = 50;

n_trials1 = 100;

t = 1:n_samples;
trial_group_1 = randn(n_samples,n_trials1) + repmat([zeros(1,10) ampl_1st_clus*ones(1,first_cluster_length) zeros(1,20) ampl_2nd_clus*ones(1,second_cluster_length) zeros(1,n_samples-10-first_cluster_length-20-second_cluster_length)]',1,n_trials1); % first dim is time, last dim is trials
trial_group_2 = fixed_value*ones(n_samples,1);
% trial_group_2 = mean(trial_group_1(1:50,:),2);

m1 = mean(trial_group_1,2);
m2 = mean(trial_group_2,2);
e1 = std(trial_group_1,0,2);
e2 = std(trial_group_2,0,2);


for s = 1:n_samples,
    % simple one sample t-test
    [h(s),p(s)] = ttest(trial_group_1(s,:),trial_group_2(s,1),'Alpha',p_crit);
end

%% Use modified version of Ben's code from testsim_BenClusterPermtTest, with one sample ttest
% [hh,pValCont] = testsim_BenClusterPermtTest(trial_group_1',trial_group_2',nperms);
 
alpha = 0.05;

Cond1 = trial_group_1';
Cond2 = trial_group_2';
 
n1 = size(Cond1,1); 
n2 = size(Cond2,1);

Maxclustertval = nan(nperms,1);
parfor randi=1:nperms
    
    randvec=randperm(n1); % generate random vector
    
    Cond1Perm = Cond1; 
    Cond1Perm(randvec(1:n1/2),:) = repmat(Cond2,n1/2,1) - Cond1Perm(randvec(1:n1/2),:);
    
    [~,p,~,stats] = ttest(Cond1Perm,0,'Alpha',alpha);
    [sigPermpos NUMpos] = bwlabeln(p <= alpha & stats.tstat > 0);
    [sigPermneg NUMneg] = bwlabeln(p <= alpha & stats.tstat < 0);
    
    clustertval = nan(NUMpos+NUMneg,1);
    for i = 1 : NUMpos;
        clustertval(i) = sum(abs(stats.tstat(sigPermpos == i)));
    end
    for i = 1 : NUMneg;
        clustertval(i+NUMpos) = sum(abs(stats.tstat(sigPermneg == i)));
    end
    
    if isempty(clustertval)
        Maxclustertval(randi) = 0;
    else
        Maxclustertval(randi) = max(clustertval);
    end
end
clear randvec Cond1Perm p stats clustertval 

[~,p,~,stats] = ttest(repmat(Cond2,n1,1) - Cond1,0,'Alpha',alpha);
[sigRealpos NUMpos] = bwlabeln(p <= alpha & stats.tstat > 0);
[sigRealneg NUMneg] = bwlabeln(p <= alpha & stats.tstat < 0);

clustertvalReal = nan(NUMpos+NUMneg,1);
for i = 1 : NUMpos;
    clustertvalReal(i) = sum(abs(stats.tstat(sigRealpos == i)));
end
for i = 1 : NUMneg;
    clustertvalReal(i+NUMpos) = sum(abs(stats.tstat(sigRealneg == i)));
end

pvalCluster = nan(length(clustertvalReal),1);
pValCont = ones(size(Cond1,2),1);
for i = 1 : length(clustertvalReal)
    pvalCluster(i) = sum(Maxclustertval >= clustertvalReal(i))/nperms;
    if i <= NUMpos
        pValCont(sigRealpos == i) = pvalCluster(i);
    else
        pValCont(sigRealneg == i-NUMpos) = pvalCluster(i);
    end
end
hh = pValCont < alpha;


%%
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
    
    
    if sum(hh)>0,
        plot(find(hh>0),0,'ro','MarkerSize',10);
    end
    
     
end