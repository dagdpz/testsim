function testsim_random_seq

N_tests = 10000;

for k = 1:N_tests,
    
    L_prob = 0.5;
    n_trials = 1000;
    seq = randsample([1 2],n_trials,true,[L_prob 1-L_prob]);
    
    
    [H_runs(k),p_runs(k)] = runstest(seq);
    
end

fprintf('%d trial length sequences: %d out of %d (%.1f percent) significant\n',n_trials,sum(H_runs),N_tests,sum(H_runs)/N_tests*100);