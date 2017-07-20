% testsim_hit_rate

real_hit_rate = 0.5;

n_trials = 10000;
prob_represent_after_miss = 1;
prob_change_after_miss = 1;

o(1) = rand>0.5;

for t=2:n_trials,
	
	o(t) = rand<real_hit_rate;

	if rand<prob_represent_after_miss && o(t-1)==0,
		o(t) = rand<prob_change_after_miss;
	end
	
	
end


success = sum(o)/n_trials

