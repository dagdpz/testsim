% wtm_wager_task_Human_4Principle.m

% 6 wagers, 1 difficulty level

perf = 0.7; % overall perceptual performance

N_trials = 100;

% payoff matrix
% constructed after 4 Principles
% 1. Higher than chance performance should be rewarded
% 2. Detection of correct and incorrect decisions should be rewarded
% -> Difference in proportion of using 3 wagers for correct vs. incorrect trials
% 3. Non-discriminative risky behavior will be counteracted by a long timeout
% 4. Difference between I don't know and I made an error (for not rational subjects which are influenced by loss aversion)


% Correct > incorrect except low wager
PayOff =	[0   0.07  0.13 0.17 0.21 ;  % correct
	0  -0.3 -0.11 -0.21 -0.26]; % incorrect

behavioral_pattern = 'UNIdirectional_metacognition_detectsCorrect'

switch behavioral_pattern
	case 'UNIdirectional_metacognition_detectsCorrect'
		wager_proportions = [	 0   0  0.2  0.2    0.6;
			0.2 0.2 0.2  0.2    0.2];
		
	case 'not_risky_UNIdirectional_metacognition_detectsInCorrect'
		wager_proportions = [	0.1 0.3 0.6;
			0.6 0.3 0.1];
		
	case 'not_risky_bidirectional_metacognition'
		wager_proportions = [	 0   0  0.1  0.1    0.6;
			0.2 0.2 0.2  0.2    0.2];
		
		wager_proportions = [	0.1 0.3 0.6;
			0.6 0.3 0.1];
		
	case 'random_uniform_wagering'
		wager_proportions = [	0.33 0.33 0.33;
			0.33 0.33 0.33];
		
	case 'bidirectinoal_metacognition_lossAverse'
		wager_proportions = [	0 0 1;
			0 0 1];
end

EVw = perf*PayOff(1,:) + (1-perf)*PayOff(2,:) % EV per wager given the performance

Outcomes = [
	N_trials*perf*wager_proportions(1,:).*PayOff(1,:);
	N_trials*(1-perf)*wager_proportions(2,:).*PayOff(2,:)]

EarningsPerWager = sum(Outcomes,1) % summary earnings of each of 3 wagers, given the performance and each wager frequency

Earnings = sum(EV)






