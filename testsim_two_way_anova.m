% try_two_way_anova
% http://www.statisticshell.com/docs/twoway.pdf


alcohol = repmat([1; 1; 2; 2; 3; 3],8,1);
gender = repmat([1; 2],24,1);
rating = [
65
50
70
45
55
30
70
55
65
60
65
30
60
80
60
85
70
30
60
65
70
65
55
55
60
70
65
70
55
35
55
75
60
70
60
20
60
75
60
80
50
45
55
65
50
60
50
40
];

[p,table,stats,terms] = anovan(rating,[alcohol gender],'model','full','varnames',{'alcohol' 'gender'})
c = multcompare(stats)


DF_main1 = length(unique(alcohol))-1
DF_main2 = length(unique(gender)) -1
DF_interaction = DF_main1*DF_main2
DF_error = length(rating) -  length(unique(alcohol))*length(unique(gender))



% compare with non-parametric Friedman test, on alcohol factor (8x2 repetitions, ignoring two genders)
% Friedman is presumably for one-way repeated measures ANOVA, but here it is used for one factor, and rows are blocks (observations) and/or a "nuisance" factor
r = reshape(rating,6,8)';
r = reshape(r,16,3); % alcohol in columns
[p,tbl,stats] = friedman(r,8); % when using reps=1, p value (0.0009) is equal ot InStat repeated measured Friedman: friedman(r,1)

% compare with non-parametric Kruskal-Wallis test, on alcohol factor (8x2 repetitions, ignoring two genders)
[p,tbl,stats] = kruskalwallis(r); % (same results as InStat)
