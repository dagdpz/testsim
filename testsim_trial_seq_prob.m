% testsim_trial_seq_prob
% Given a choice bias, what is probability one choice (L,1) is preceded/followed by another (R,2)?
% "the conditional probability of A given B" or "the probability of A under the condition B"
% P(A|B), or P_B(A)


% Examples, all assume L = 1, R = 2

% 1. Completely random 
% L_prob = 0.72;
% n_trials = 100;
% seq = randsample([1 2],n_trials,true,[L_prob 1-L_prob]);

% 2.
% seq = [1 2 2 2 2 2 2 2 2 2 1 2 2 2 2 2 2 2 2 2 2]; n_trials = length(seq);
% prob. of 1 preceded by 1 = 0; prob. of 1 preceded by 2 = 1; prob. of 2 preceded by 1 = 0.1; prob. of 2 preceded by 2 = 0.9; 
% prob. of 1 followed by 1 = 0; prob. of 1 followed by 2 = 1; prob. of 2 followed by 1 = .06; prob. of 2 followed by 2 = 0.94;

% 3.
% seq = [1 1 2 2 2 2 2 2 2 2 2 1 1 2 2 2 2 2 2 2 2 2 2]; n_trials = length(seq);
% prob. of 1 (current) preceded by 1 (preceding) = 0.67; prob. of 1 (current) preceded by 2 = 0.33;
% prob. of 2 (current) preceded by 1 (preceding) = 0.1; prob. of 2 (current) preceeded by 2 = 0.9;
% P(1|1) 0.67	P(2|1) 0.33
% P(1|2) 0.1	P(2|2) 0.9
% P(preceding|current)
%
% prob. of 1 (current) followed by 1 (next) = 0.5; prob. of 1 followed by 2 = 0.5; prob. of 2 (current) followed by 1 (next) = .06; prob. of 2 followed by 2 = 0.94;
% P(1|1) 0.5	P(2|1) 0.5
% P(1|2) 0.06	P(2|2) 0.94
% P(next|current)

% 4. Markov chain of 1st order
% n_trials = 10000;
% TM = [0.1 0.9; 0.8 0.2]; % transition matrix
% seq = testsim_markov_chain(n_trials,TM,1); % states 1 and 2
% Explanation
% Here:		P(next|current)	
%		P(1|1)	P(2|1)
%		P(1|2)	P(2|2)
%		0.1	0.9
%		0.8	0.2
% Theoretical P(1) and P(2) (let's call them q1 and q2)
% See https://en.wikipedia.org/wiki/Examples_of_Markov_chains > A simple weather model
% P = TM - [1 0; 0 1];
% q1 = -P(2,1)/(P(1,1)-P(2,1)) % L_prob_theoretical

% 5. Markov chain of 1st order, equal transitions
n_trials = 10000;
TM = [0.25 0.75; 0.25 0.75]; % transition matrix
seq = testsim_markov_chain(n_trials,TM,1); % states 1 and 2
% P = TM - [1 0; 0 1];
% q1 = -P(2,1)/(P(1,1)-P(2,1)) % L_prob_theoretical


% output
L_prob_actual = length(find(seq==1))/n_trials

param.conditions_compare_vs_LR	= [1 2 3]; % condtions to compare to preceeding/next L or R conditions
param.group_LR			= {[1 3 5] [2 4 6]}; % two groups, one left and one right (can also include conditions_compare_vs_LR) 
out = ig_analyze_trial_sequence('seq',seq,'condition_labels',{{'L' 'R'}},'group_conditions',{{[1 2]}},'conditions_compare_vs_LR',[1 2],'group_LR',{{[1] [2]}});

out.Ppc
out.Pnc

% https://en.wikipedia.org/wiki/Approximate_entropy
% apen = ApEn(2,0.2*std(seq),seq)

% https://en.wikipedia.org/wiki/Sample_entropy
SampEn = sampen(seq,1,0.2*std(seq))

% runs test https://en.wikipedia.org/wiki/Wald%E2%80%93Wolfowitz_runs_test
[H_runs,p_runs] = runstest(seq)