function testsim_binomial_prob
% binomial probabilities of binary outcomes
% see http://www.socscistatistics.com/tests/binomial/Default2.aspx

% 1. testing correspondence between binomial prob and random permutations
% n_trials = 1000;
% random_prob_of_success = 0.5; % in case of random outcomes
% n_success = 527; % for 1000 trials with 0.5 random prob, 526 trials correct trials can occur at random at p 0.05, p_binom = 0.0468, but at n_success = 526, p_binom = 0.0534

% 2. Curius example M2S 2nd session, 2017
n_trials = 1454;
random_prob_of_success = 0.333; % in case of random outcomes
n_success = 565; 

p_binom = myBinomTest(n_success,n_trials,random_prob_of_success,'one') % part of Igtools/external


% now test using permutations
% see https://cogsci.stackexchange.com/questions/13386/in-a-forced-choice-task-what-proportion-of-responses-is-above-chance-level
p_cutoff = 0.05;
n_permutations = 100000;

% Create an array of n_permutations x n_trials random guesses, 0 ... n, where n is correct response
random_responses = randi([0 fix(1/random_prob_of_success)-1],[n_permutations n_trials]);

% Compute the fraction correct for each permutation (correct response is a maximal value)
fraction_correct = sum(random_responses==max(max(random_responses)),2)/n_trials;

% Compute and print the cutoff performance percentage for desired p value to be above chance
fprintf('\np=%1.3f cutoff for %d trials: %3.1f%%, %d correct trials\n\n', p_cutoff, n_trials, quantile(fraction_correct,1-p_cutoff)*100,n_trials*quantile(fraction_correct,1-p_cutoff));

% OBSOLETE:
% Another way as in the https://cogsci.stackexchange.com/questions/13386/in-a-forced-choice-task-what-proportion-of-responses-is-above-chance-level
% BUT TAKING SEQUENCE OF TRIALS IS NOT NEEDED, WE ARE ONLY INTERESTED IN HOW MANY CORRECT 

% % Create a vector of n_trials 'correct' responses and replicate it across n_permutations
% expected_values = repmat(randi([0 1],[1 n_trials]),[n_permutations 1]);
% 
% % Create an array of n_permutations x n_trials random guesses
% random_responses = randi([0 1],[n_permutations n_trials]);
% 
% % Compute the fraction correct for each permutation
% fraction_correct = sum(expected_values==random_responses,2)/n_trials;
% 
% % Compute and print the cutoff performance percentage for desired p value to be above chance
% fprintf('\np=%1.3f cutoff for %d trials: %3.1f%%, %d correct trials\n\n', p_cutoff, n_trials, quantile(fraction_correct,1-p_cutoff)*100,n_trials*quantile(fraction_correct,1-p_cutoff));

