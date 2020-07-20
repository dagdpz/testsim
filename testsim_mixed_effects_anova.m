% testsim_mixed_effects_anova

% http://www.statisticshell.com/docs/mixed.pdf -> https://www.discoveringstatistics.com/repository/mixed_2020.pdf
% https://en.wikipedia.org/wiki/Mixed-design_analysis_of_variance

santa = repmat([1; 2; 3],12,1);
rater = [ones(18,1); 2*ones(18,1)];

rating = [
% elves, 1
1
3
1
2
5
3
4
6
6
5
7
4
5
9
1
6
9
3
% deer, 2
1
10
2
4
8
1
5
7
3
4
9
2
2
10
4
5
10
2
];

% [p,table,stats,terms] = anovan(rating,[santa rater],'model','full','random',1,'varnames',{'Santa' 'Rater'}); % not working for mixed effects

% reformat for [SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(X,suppress_output)

subj = reshape(repmat([1:12],3,1),36,1);

X = [rating rater santa subj];

% clear X; % other examples
% 
% X(1:24,1) = rand(24,1);
% X(1:24,2) = [1 1 1 1 1 1 2 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2];
% X(1:24,3) = [1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2];
% X(1:24,4) = [1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 11 11 12 12];

% clear X; % other examples
% X(1:34,1) = rand(34,1);
% X(1:34,2) = [ones(1,6) 2*ones(1,11) ones(1,6) 2*ones(1,11)];
% X(1:34,3) = [ones(1,17) 2*ones(1,17)];
% X(1:34,4) = [1:17 1:17];

% X: design matrix with four columns (future versions may allow different input configurations)
%     - first column  (i.e., X(:,1)) : all dependent variable values
%     - second column (i.e., X(:,2)) : between-subjects factor (e.g., subject group) level codes (ranging from 1:L where 
%         L is the # of levels for the between-subjects factor)
%     - third column  (i.e., X(:,3)) : within-subjects factor (e.g., condition/task) level codes (ranging from 1:L where 
%         L is the # of levels for the within-subjects factor)
%     - fourth column (i.e., X(:,4)) : subject codes (ranging from 1:N where N is the total number of subjects)

[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(X) % works very well, corresponds to SPSS http://www.statisticshell.com/docs/mixed.pdf


% now try unbalanced groups: 6 elves but 4 deer

% rating = [
% % elves, 1
% 1
% 3
% 1
% 2
% 5
% 3
% 4
% 6
% 6
% 5
% 7
% 4
% 5
% 9
% 1
% 6
% 9
% 3
% % deer, 2
% 1
% 10
% 2
% 4
% 8
% 1
% 5
% 7
% 3
% 4
% 9
% 2
% ];
% 
% santa = repmat([1; 2; 3],10,1);
% rater = [ones(18,1); 2*ones(12,1)];
% 
% subj = reshape(repmat([1:10],3,1),30,1);
% 
% X = [rating rater santa subj];
% 
% [SSQs, DFs, MSQs, Fs, Ps]=mixed_between_within_anova(X)

% between subjects
DF_bs_factor = length(unique(X(:,2)))-1
DF_bs_error = length(unique(X(:,4))) - length(unique(X(:,2)))

% within subjects
DF_ws_factor = length(unique(X(:,3)))-1
DF_ws_interaction = DF_bs_factor*DF_ws_factor
DF_ws_error = DF_bs_error* DF_ws_factor

