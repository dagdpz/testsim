% testsim_baseline_correction_paired_nonpaired
close

N_trials = 20; % number of trials
noise_trial2trial_sd = 10; % trial to trial noise, same for the baseline and response
b_mean = 0;
response_mean = 1;
response_sd = 1;
    
if 1 % simulate average response amplitude
    
    b = normrnd(b_mean,noise_trial2trial_sd,[N_trials,1]);
    r = b + normrnd(response_mean,response_sd,[N_trials,1]);
    
    if 0 % baseline correction
        b = b - b;
        r = r - b;
        
        % NOTE: baseline correction invalidates the "pairing"!
    end
    
    if 0 % absolute
        b = abs(b);
        r = abs(r);
    end
    
else % simulate timecoures
    n_samples = 100; % per epoch
    btt = repmat(normrnd(b_mean,noise_trial2trial_sd,[N_trials,1]),1,n_samples);
    bt = btt + normrnd(b_mean,1,[N_trials,n_samples]); % trial x sample
    rt = btt + normrnd(response_mean,response_sd,[N_trials,n_samples]);
    
    if 1 % baseline correction
        bc = repmat(mean(bt,2),1,n_samples);
        bt = bt - bc;
        rt = rt - bc;
    end
    
    if 0 % absolute
        bt = abs(bt);
        rt = abs(rt);
    end
    
    b = mean(bt,2);
    r = mean(rt,2);
    
    subplot(2,1,1)
    plot([bt rt]');
    
end



subplot(2,1,2)
plot([1 2],[b r],'ko'); hold on
plot([1 2],[b r],'k-'); hold on


[h,p] = ttest(b,r) % paired ttest
[h2,p2] = ttest2(b,r) % nonpaired ttest

% Wilcoxon signed rank test
[P,H] = signrank(b,r)
