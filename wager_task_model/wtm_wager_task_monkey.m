% wtm_wager_task_monkey

% 3 wagers, 1 difficulty level

perf = 0.50

N_trials = 100;

% payoff matrix

% EV same for all wagers
% PayOff =	[0  1  4; % correct
% 		0  1  4]; % incorrect

% Balanced
% PayOff =	[0  1  4; % correct
% 		2  1  -2]; % incorrect

% Strong punishment for risky behavior
% PayOff =	[0  1  4; % correct
% 		2  1  -3.9]; % incorrect
	
	
% Inverted for correct and incorrect: not good, since there is no effect of performance
% PayOff =	[-3.9  1  4; % correct
% 		4  1  -3.9]; % incorrect

% ...
% PayOff =	[0  1  4; % correct
% 		4  1  -3.9]; % incorrect
	
% a la Middlebrooks and Sommers 2011, except low wager
% PayOff =	[0  2  4; % correct
% 		2  1  -2]; % incorrect

% Correct > incorrect except low wager
% PayOff =	[0  2  4; % correct
% 		1  0  -3.9]; % incorrect

PayOff =	[0  3  5; % correct
		2  1  -4.9]; % incorrect


behavioral_pattern = 'moderately_risky_no_metacognition';

switch behavioral_pattern
	
	case 'not_risky_bidirectional_metacognition'
		wager_proportions = [	0.1 0.3 0.6;
					0.6 0.3 0.1];
	case 'moderately_risky_bidirectional_metacognition'		
		wager_proportions = [	0.1 0.2 0.7;
					0.3 0.2 0.5];				
	case 'random_uniform_wagering'
		wager_proportions = [	0.33 0.33 0.33;
					0.33 0.33 0.33];
	case 'absolutely_risky_no_metacognition'
		wager_proportions = [	0 0 1;
					0 0 1];
	case 'moderately_risky_no_metacognition'
		wager_proportions = [	0.2 0.4 0.4;
					0.2 0.4 0.4];			
				
end

%--
% wager_proportions = [ 0 0.5 0.5; 1 0 0];
wager_proportions = [ 0 0 1; 0.5 0.5 0];

PayOff = round2(wtm_utility([0 2 5; 3 1 -45]),0.1)
%--
EVw = perf*PayOff(1,:) + (1-perf)*PayOff(2,:) % EV per wager given the performance

% 
Outcomes = [
	N_trials*perf*wager_proportions(1,:).*PayOff(1,:);
	N_trials*(1-perf)*wager_proportions(2,:).*PayOff(2,:)]

EarningsPerWager = sum(Outcomes,1) % summary earnings of each of 3 wagers, given the performance and each wager frequency

Earnings = sum(EarningsPerWager)






