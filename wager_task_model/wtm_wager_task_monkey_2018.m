% wtm_wager_task_monkey
clear all; clc; 
% Properties for the Program
saveAsMatlabFigures      = 1;
saveAsExcelTable         = 0; 
%% TODO
% 1) How to integrate time as an dependent variable
% 3) graphs to 
% 2) strategy: difficulty Levels
%% Explaination
% 3 wagers, 1 difficulty level, fixed amount of trials in the beginning
Perf            = 0.75;
N_trials        = 100;
Time_perTrial   = 5; %s
TimeOut         = 4; 

%% 3 Principles - how to construct the payoff matrix
% 1. Higher than chance performance should be rewarded
% 2. Detection of correct and incorrect decisions should be rewarded
% -> Difference in proportion of using 3 wagers for correct vs. incorrect trials
%2.2 Difference between I don't know/uncertain-option and I made an error (for not rational subjects which are influenced by loss aversion)
% 3. Non-discriminative risky behavior will be counteracted by a long timeout

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
PayOff =	[0  0.2  0.5; % correct
            0.3  0.1  -15]; % incorrect

%% transformation of the payoff-matrix
%GAIN
Gain_PayOff                   = PayOff;
Gain_PayOff(Gain_PayOff<0)    = 0;
%TIME/Loss
Time_perTrial                 = 5; %s % each trial has an average time to be completed
Time_PayOff                   = PayOff; 
Time_PayOff(PayOff(1,:)>= 0)  = Time_perTrial; 
Time_PayOff(2,PayOff(2,:)>=0) = Time_perTrial; 
Time_PayOff                   = abs( Time_PayOff);

% convertion from Time into units of Reward to calculate Utility
% IK: better to convert before the Power-function
% ex. 1Rw -> 5s; 
% !! 
Coefficient     =    31; 
PayOff_RW       =	 wtm_ConvertTimeOut2Reward(PayOff,Coefficient);
par_R = [1.5, 2, 4]; %gains
par_T = 0.9;
% risk seeking
par_S = 1  ;
BigTable = []; 
for ind_R = 1: length(par_R)
    disp(['R-Parameter changed', num2str(par_R(ind_R))])
Utility_PayOff = wtm_utility( PayOff_RW,[par_R(ind_R),par_T,par_S] );

%% the behavior pattern to chose a wager
% how often each wager were choosen? 
% separated for Correct & Incorrect trials -> each adding up to 100%
% are the proporting of wagers perceived as independently between Incorrect
% and Correct proportions? 
Allbehavioral_pattern = {...
		'random_uniform_wagering',...
		'moderatelyRisky_NoMetacognition',...
		'absolutelyRisky_NoMetacognition' ,...
		'UncertainOption_NoMetacognition',...
		'moderatelyRisky_bidirectionalMetacognition',...
		'notRisky_bidirectionalMetacognition',...
		'Certainty_Correct', ...
		%'Following_Feedback_100%',...
		};

Table = []; T  = [];
for i_behaviors = 1:size(Allbehavioral_pattern,2)
	
	behavioral_pattern = Allbehavioral_pattern{i_behaviors};
	switch behavioral_pattern
		
		case 'random_uniform_wagering'
			wager_proportions = [	0.33 0.33 0.33;
                                    0.33 0.33 0.33];
        case 'moderatelyRisky_NoMetacognition'
			wager_proportions = [	0 0.2 0.8;
                                    0 0.2 0.8];   
		case 'absolutelyRisky_NoMetacognition'
			wager_proportions = [	0 0 1;
                                    0 0 1];
		case 'UncertainOption_NoMetacognition'
			wager_proportions = [	0 1 0;
                                    0 1 0];                                
       case 'Certainty_Correct'
			wager_proportions = [	0.0 0.5 0.5;
                                    0.33 0.33 0.33];
        case 'moderatelyRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.2 0.7;
                                    0.3 0.2 0.5];
        case 'notRisky_bidirectionalMetacognition'
			wager_proportions = [	0.1 0.3 0.6;
                                    0.6 0.3 0.1];
		case 'Certainty_Correct_perf'
			wager_proportions = [	0 0 1;
                                    0 0.5 0.5];
		case 'Following_Feedback_100%'
			wager_proportions = [	0 0 1;
                                    1 0 0];
	end
	
	EVw = Perf*Utility_PayOff(1,:) + (1-Perf)*Utility_PayOff(2,:); % EV per wager given the performance
	
GainOutcomes = [
		N_trials*Perf*wager_proportions(1,:).*Gain_PayOff(1,:);
		N_trials*(1-Perf)*wager_proportions(2,:).*Gain_PayOff(2,:)];

Utility_Outcomes = [
		N_trials*Perf*wager_proportions(1,:).*Utility_PayOff(1,:);
		N_trials*(1-Perf)*wager_proportions(2,:).*Utility_PayOff(2,:)];    
TimeOutcomes = [
		N_trials*Perf*wager_proportions(1,:).*Time_PayOff(1,:);
		N_trials*(1-Perf)*wager_proportions(2,:).*Time_PayOff(2,:)];
	
   	format short g
 
    
    
    GainPerWager    = sum(GainOutcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
	T.TimePerWager  = sum(TimeOutcomes,1);
	T.Gain          = sum(sum(GainOutcomes,1));

    T.Gain            = sum(GainPerWager);
	T.Time                = sum(T.TimePerWager);
    T.EarningsUtiity    = sum(sum(Utility_Outcomes,1)); 

	T.R_ParUtil = par_R(ind_R);
    T.T_ParUtil =  par_T;
    T.S_ParUtil =  par_S;
	T.behavioral_pattern	= {behavioral_pattern};
	T.NrTrials              = N_trials;
	T.NeedTrials_CompensateNoMetacognition           = N_trials;
	T.payoff_correct        = {num2str(PayOff(1,:))};
	T.payoff_incorrect      = {num2str(PayOff(2,:))};
    T.PayOff_RW_correct        = {num2str(PayOff_RW(1,:))};
	T.PayOff_RW_incorrect      = {num2str(PayOff_RW(2,:))};
    
    T.PayOff_Utility_correct        = {num2str(Utility_PayOff(1,:))};
	T.PayOff_Utility_incorrect      = {num2str(Utility_PayOff(2,:))};
	T.EVw                   =  {num2str(EVw)};
	T.EarningsPerWager      = {num2str(round(GainPerWager,2))};
	T.Perf                  = Perf;
	T.NrTrials              = N_trials;
	T.wagerProportions_behavioral_pattern1 = wager_proportions(1,:);
	T.wagerProportions_behavioral_pattern2 = wager_proportions(2,:);
	T.Nr_BehPattern = i_behaviors; 

	Row = struct2table(T);
	Table = [Table; Row];
	
	% sort the behavioral strategy according to earnings
	
end

%% How many trials are need to have the same outcome as the strategy with the highest earnings
for i_behaviors = 1:size(Allbehavioral_pattern,2)
	
	behavioral_pattern = Allbehavioral_pattern{i_behaviors};
	wager_proportions1 = Table.wagerProportions_behavioral_pattern1(i_behaviors,:);
	wager_proportions2 = Table.wagerProportions_behavioral_pattern2(i_behaviors,:);
	
	
	NeedTrials_CompensateNoMetacognition = Table.NrTrials(i_behaviors);
	EarningsUtiity = Table.EarningsUtiity(i_behaviors);
	while max(Table.EarningsUtiity) > EarningsUtiity 
        disp(max(Table.EarningsUtiity)); disp(EarningsUtiity)
		NeedTrials_CompensateNoMetacognition = NeedTrials_CompensateNoMetacognition +1;
		Outcomes = [
			NeedTrials_CompensateNoMetacognition*Perf*wager_proportions1.*Utility_PayOff(1,:);
			NeedTrials_CompensateNoMetacognition*(1-Perf)*wager_proportions2.*Utility_PayOff(2,:)];
		
		EarningsPerWager = sum(Outcomes,1); % summary earnings of each of 3 wagers, given the performance and each wager frequency
		EarningsUtiity = [];
		EarningsUtiity = sum(EarningsPerWager);
		Table.NeedTrials_CompensateNoMetacognition(i_behaviors) = NeedTrials_CompensateNoMetacognition;
        if  EarningsUtiity > -500 
            break
        elseif EarningsUtiity < 500
            break
        end
	end
	Table.NeedTrials_CompensateNoMetacognition(i_behaviors) = Table.NeedTrials_CompensateNoMetacognition(i_behaviors) -100;
end

Table = sortrows(Table,'EarningsUtiity');
Table.Nr_BehPattern(:) = 1:length(Table.Nr_BehPattern); 

BigTable =  [BigTable ; Table];
%% Excel Table
if saveAsExcelTable 
writetable(BigTable,'Y:\Projects\Wagering_monkey\Results\PayoffMatrix\Overview_PayOff_Utility.xls', 'Sheet',1);
end
%% graphical display
figure(ind_R) %Earnings per  Behavioral-Wagering-Pattern
disp(['Figure', num2str(ind_R)])
annotation('textbox', [0, 1,0.1,0], 'string', 'PayOff'); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.98,0.1,0], 'string', num2str(PayOff(1,:))) ;%annotation('textbox',[x y w h]
annotation('textbox', [0, 0.95,0.1,0], 'string', num2str(PayOff(2,:)));

annotation('textbox', [0, 0.9,0.1,0], 'string', 'Transformed to Reward-Payoff'); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.88,0.1,0], 'string', num2str(PayOff_RW(1,:))); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.85,0.1,0], 'string', num2str(PayOff_RW(2,:)));

annotation('textbox', [0, 0.8,0.1,0], 'string', 'Transformed to Utility-Payoff') %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.78,0.1,0], 'string', num2str(round(Utility_PayOff(1,:),2))); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.75,0.1,0], 'string', num2str(round(Utility_PayOff(2,:),2)));


annotation('textbox', [0, 0.7,0.1,0], 'string', 'Parameter for utility'); %annotation('textbox',[x y w h]
a = annotation('textbox', [0, 0.68,0.1,0], 'string', ['R =', num2str( par_R(ind_R))]); %annotation('textbox',[x y w h]
a.Color = 'red'; 

ax1 = subplot(6,1,1);
bar(  Table.Nr_BehPattern, Table.EarningsUtiity) 
set(gca,'xlim',[min(Table.Nr_BehPattern)-1 max(Table.Nr_BehPattern)+1 ]); 
set(gca,'Xtick', [] )
%set(gca, 'XTickLabelRotation',45)
ylabel('utility','fontsize',20,'fontweight','b' );
title('Earnings (utility) per  Behavioral-Wagering-Pattern','fontsize',20,'fontweight','b' );
set(gca, 'TickLabelInterpreter', 'none')

ax1 = subplot(6,1,2);%Additionally completed Trials per  Behavioral-Wagering-Pattern
bar(  Table.Nr_BehPattern, Table.NeedTrials_CompensateNoMetacognition) 
set(gca,'xlim',[min(Table.Nr_BehPattern)-1 max(Table.Nr_BehPattern)+1 ]); 
set(gca,'Xtick', [] )
%set(gca, 'XTickLabelRotation',45)
ylabel('Nr.Trials','fontsize',20,'fontweight','b' );
title('Additionally completed Trials per  Behavioral-Wagering-Pattern','fontsize',20,'fontweight','b' );
set(gca, 'TickLabelInterpreter', 'none')

ax1 = subplot(6,1,3);%Additionally completed Trials per  Behavioral-Wagering-Pattern
bar(  Table.Nr_BehPattern, Table.Gain) 
set(gca,'xlim',[min(Table.Nr_BehPattern)-1 max(Table.Nr_BehPattern)+1 ]); 
set(gca,'Xtick', [] )
%set(gca, 'XTickLabelRotation',45)
ylabel('Gain (ml)','fontsize',20,'fontweight','b' );
%title('Reward per  Behavioral-Wagering-Pattern','fontsize',20,'fontweight','b' );
set(gca, 'TickLabelInterpreter', 'none')

ax1 = subplot(6,1,4);%Additionally completed Trials per  Behavioral-Wagering-Pattern
bar(  Table.Nr_BehPattern, Table.Time) 
set(gca,'xlim',[min(Table.Nr_BehPattern)-1 max(Table.Nr_BehPattern)+1 ]); 
ylabel('Time (s)','fontsize',20,'fontweight','b' );
%title('Time per  Behavioral-Wagering-Pattern','fontsize',20,'fontweight','b' );
set(gca,'Xtick', [] )

ax1 = subplot(6,1,5);%Additionally completed Trials per  Behavioral-Wagering-Pattern
b = bar(Table.wagerProportions_behavioral_pattern1, 'Stacked') ; 
title('proportion of each wager','fontsize',15,'fontweight','b')
ylabel('correct','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');set(gca,'Xtick', [] )
legend(b, {'wager1', 'wager2', 'wager3'})
ax1 = subplot(6,1,6);%Additionally completed Trials per  Behavioral-Wagering-Pattern

b = bar(Table.wagerProportions_behavioral_pattern2, 'Stacked') ; 
ylabel('incorrect','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');
set(gca,'XtickLabel', cellstr(Table.behavioral_pattern),'fontsize',7)
set(gca, 'XTickLabelRotation',45)

%display the Behavioral-Wagering-Pattern
% display expected Value for each Wager

% add NumTrials & PayoffMatrix
%

end
%% Compare the defined risk seeking with the parameter
figure(length( par_R)+1) %Earnings per  Behavioral-Wagering-Pattern
annotation('textbox', [0, 1,0.1,0], 'string', 'PayOff'); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.98,0.1,0], 'string', num2str(PayOff(1,:))) ;%annotation('textbox',[x y w h]
annotation('textbox', [0, 0.95,0.1,0], 'string', num2str(PayOff(2,:)));

annotation('textbox', [0, 0.9,0.1,0], 'string', 'Transformed to Reward-Payoff'); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.88,0.1,0], 'string', num2str(PayOff_RW(1,:))); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.85,0.1,0], 'string', num2str(PayOff_RW(2,:)));

annotation('textbox', [0, 0.8,0.1,0], 'string', 'Transformed to Utility-Payoff') %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.78,0.1,0], 'string', num2str(round(Utility_PayOff(1,:),2))); %annotation('textbox',[x y w h]
annotation('textbox', [0, 0.75,0.1,0], 'string', num2str(round(Utility_PayOff(2,:),2)));


annotation('textbox', [0, 0.7,0.1,0], 'string', 'Parameter for utility'); %annotation('textbox',[x y w h]
a = annotation('textbox', [0, 0.68,0.1,0], 'string', ['R =', num2str(par_R(ind_R))]); %annotation('textbox',[x y w h]
a.Color = 'red'; 

ax1 = subplot(5,1,1);
bar(  Table.Nr_BehPattern, Table.EarningsUtiity) 
set(gca,'xlim',[min(Table.Nr_BehPattern)-1 max(Table.Nr_BehPattern)+1 ]); 
set(gca,'Xtick', [] )
%set(gca, 'XTickLabelRotation',45)
ylabel('utility','fontsize',20,'fontweight','b' );
title('Earnings (utility) per  Behavioral-Wagering-Pattern','fontsize',20,'fontweight','b' );
set(gca, 'TickLabelInterpreter', 'none')


ax1 = subplot(5,1,4);%Additionally completed Trials per  Behavioral-Wagering-Pattern

b = bar(Table.wagerProportions_behavioral_pattern1, 'Stacked') ; 
title('proportion of each wager','fontsize',15,'fontweight','b')
ylabel('correct','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');set(gca,'Xtick', [] )
legend(b, {'wager1', 'wager2', 'wager3'})
ax1 = subplot(6,1,5);%Additionally completed Trials per  Behavioral-Wagering-Pattern

b = bar(Table.wagerProportions_behavioral_pattern2, 'Stacked') ; 
ylabel('incorrect','fontsize',15,'fontweight','b' );
set(gca, 'box', 'off');
set(gca,'XtickLabel', cellstr(Table.behavioral_pattern),'fontsize',10)
set(gca, 'XTickLabelRotation',45)


%% Save Graphs
if saveAsMatlabFigures 
path_SaveFig = ['Y:\Projects\Wagering_monkey\Program\payoff-Matrix\Graphs_WagerModel_Monkey']; 
for i = 1:3
    h(i) = figure(i); 
end  
savefig(h, [path_SaveFig  'Graphs_WagerModel.fig'])
else 
end
