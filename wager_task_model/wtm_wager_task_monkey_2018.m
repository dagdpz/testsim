% wtm_wager_task_monkey_2018

% wtm_wager_task_monkey

% 3 wagers, 1 difficulty level

% constructed after 4 Principles
% 1. Higher than chance performance should be rewarded
% 2. Detection of correct and incorrect decisions should be rewarded
% -> Difference in proportion of using 3 wagers for correct vs. incorrect trials
% 3. Non-discriminative risky behavior will be counteracted by a long timeout
% 4. Difference between I don't know/uncertain-option and I made an error (for not rational subjects which are influenced by loss aversion)
AvPerf = 0.75;
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

% PayOff =	[0  3  5; % correct
%		2  1  -4]; % incorrect

% Expected Values of the Wagers more equal...
PayOff =	[0  2  5; % correct
            3  1  -4]; % incorrect

% ml = 0.05;
% PayOff =	[0  2*ml  5*ml; % correct
%              2*ml  1*ml  -4*ml]; % incorrect

Allbehavioral_pattern = {...
		'random_uniform_wagering:0.33 0.33 0.33',...
		'moderatelyRisky_NoMetacognition',...
		'absolutelyRisky_NoMetacognition: 0 0 1' ,...
		'UncertainOption_NoMetacognition: 0 1 0',...
		'moderatelyRisky_bidirectionalMetacognition',...
		'notRisky_bidirectionalMetacognition',...
		'Certainty_Correct', ...
		'Following_Feedback_100%',...
		};
	
Table = []; T  = [];
for i_behaviors = 1:size(Allbehavioral_pattern,2)
	
	behavioral_pattern = Allbehavioral_pattern{i_behaviors};
	switch behavioral_pattern
		
		
		case 'notRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.3 0.6;
						0.6 0.3 0.1];
		case 'moderatelyRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.2 0.7;
						0.3 0.2 0.5];
		case 'random_uniform_wagering:0.33 0.33 0.33'
			wager_proportions = [	0.33 0.33 0.33;
						0.33 0.33 0.33];
		case 'absolutelyRisky_NoMetacognition: 0 0 1'
			wager_proportions = [	0 0 1;
						0 0 1];
 		case 'moderatelyRisky_NoMetacognition'
			wager_proportions = [	0 0.2 0.8;
						0 0.2 0.8];                               
		case 'UncertainOption_NoMetacognition: 0 1 0'
			wager_proportions = [	0 1 0;
						0 1 0];
		case 'Certainty_Correct'
			wager_proportions = [	0.0 0.5 0.5;
						0.33 0.33 0.33];
		case 'Certainty_Correct_perf'
			wager_proportions = [	0 (1-AvPerf) AvPerf;
						0 (1-AvPerf)/2 (1-AvPerf)/2];
			wager_proportions = [	0 0 1;
						0 0.5 0.5];
		case 'Following_Feedback_100%'
			wager_proportions = [	0 0 1;
                                    1 0 0];
	end
	
	EVw = AvPerf*PayOff(1,:) + (1-AvPerf)*PayOff(2,:); % EV per wager given the performance
	
	Outcomes = [
		N_trials*AvPerf*wager_proportions(1,:).*PayOff(1,:);
		N_trials*(1-AvPerf)*wager_proportions(2,:).*PayOff(2,:)];
	
	EarningsPerWager = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
	
	Earnings = sum(EarningsPerWager);
	
	
	% Table
	format short g
	T.Earnings		= Earnings;
	T.behavioral_pattern	= {behavioral_pattern};
	T.NrTrials		= N_trials;
	T.NeedTrials_CompensateNoMetacognition           = N_trials;
	T.payoff_correct	 = {num2str(PayOff(1,:))};
	T.payoff_incorrect	= {num2str(PayOff(2,:))};
	T.EVw			=  {num2str(EVw)};
	T.EarningsPerWager	= {num2str(round(EarningsPerWager,2))};
	T.Perf			= perf;
	T.NrTrials		= N_trials;
	T.wagerProportions_behavioral_pattern1 = wager_proportions(1,:);
	T.wagerProportions_behavioral_pattern2 = wager_proportions(2,:);
	
	Row = struct2table(T);
	Table = [Table; Row];
	
	% sort the behavioral strategy according to earnings
	
end

% How many trials are need to have the same outcome as the strategy with the highest earnings
for I_behaviors = 1:size(Allbehavioral_pattern,2)
	
	behavioral_pattern = Allbehavioral_pattern{I_behaviors};
	wager_proportions1 = Table.wagerProportions_behavioral_pattern1(I_behaviors,:);
	wager_proportions2 = Table.wagerProportions_behavioral_pattern2(I_behaviors,:);
	
	
	NeedTrials_CompensateNoMetacognition = Table.NrTrials(I_behaviors);
	Earnings = Table.Earnings(I_behaviors);
	while max(Table.Earnings) > Earnings
		NeedTrials_CompensateNoMetacognition = NeedTrials_CompensateNoMetacognition +1;
		Outcomes = [
			NeedTrials_CompensateNoMetacognition*perf*wager_proportions1.*PayOff(1,:);
			NeedTrials_CompensateNoMetacognition*(1-perf)*wager_proportions2.*PayOff(2,:)];
		
		EarningsPerWager = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
		Earnings = [];
		Earnings = sum(EarningsPerWager);
		Table.NeedTrials_CompensateNoMetacognition(I_behaviors) = NeedTrials_CompensateNoMetacognition;
	end
	Table.NeedTrials_CompensateNoMetacognition(I_behaviors) = Table.NeedTrials_CompensateNoMetacognition(I_behaviors) -100;
end

Table = sortrows(Table,'Earnings');

% writetable(Table,'Y:\Projects\Wagering_monkey\Results\PayoffMatrix\Overview_PayOff_Outcomes.xls', 'Sheet',1)
