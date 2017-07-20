% subject-specific settings	
% easy family: hard -> easy : 1 - 5
% mid  family: hard -> easy : 6 - 10
% hard family: hard -> easy : 11- 15

disp('---------------------------------');
% run('wtm_ideal_subject_wagering_high')
% run('wtm_ideal_subject_wagering_low')
run('wtm_low_performance_subject_wagering_high')
% run('wtm_random_performance_subject_wagering_high')
% run('wtm_reasonable_performance_subject_wagering_reasonably')

		
% task settings		
% trials per conditions
n_trials	= [	0 0 40 40 40;...
			0 40 40 40 0;...
			40 40 40 0 0];
    
high_wager_loss_fine	= 0.03; % Euro
endowment		= 10;	% Euro
wagers		= [0.02 0.05 0.08 0.11 0.14 0.17]; % Euro

% END SETTINGS


n = 1;
for f = 1:3 % family
	for d = 1:5 % difficulty		
		mean_trial_wager(f,d) = wager_prob(n,:)*wagers'; % mean wager per trial for each condition
		prob_wager_high(f,d) = sum(wager_prob(n,4:6)); % probability wagering high for each condition
		n = n + 1;
	end
end

disp(sprintf('task settings: %d trials, high_wager_loss_fine %.2f Euro, endowment %d Euro ',sum(sum(n_trials)), high_wager_loss_fine, endowment));
disp(sprintf('wagers %s ',mat2str(wagers)));


mean_trial_wager

prob_wager_high

correct_trials		= perf.*n_trials; % amount of correct trials for each condition
incorrect_trials	= (1-perf).*n_trials; % amount of incorrect trials for each condition


winnings		= correct_trials.*mean_trial_wager
losses			= incorrect_trials.*mean_trial_wager + high_wager_loss_fine*incorrect_trials.*prob_wager_high

total_earnings  = endowment + nansum(nansum(winnings)) - nansum(nansum(losses))






