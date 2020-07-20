% testsim_repeated_measures_anova
% https://www.discoveringstatistics.com/repository/repeatedmeasures.pdf

% one-way repeated measures ANOVA
% bushtacker.sav : 4 different animals to eat for each subject (celebrity)
r = [
1 
8 
7 
1 
6 
2 
9 
5 
2 
5 
3 
6 
2 
3 
8 
4 
5 
3 
1 
9 
5 
8 
4 
5 
8 
6 
7 
5 
6 
7 
7 
10 
2 
7 
2 
8 
12 
6 
8 
1 
];

r = reshape(r,5,8)';
r = r(:,2:5);

% https://de.mathworks.com/matlabcentral/fileexchange/22088-repeated-measures-anova
[p, table_] = anova_rm(r);


% now MATLAB way:
t = table(r(:,1),r(:,2),r(:,3),r(:,4),...
'VariableNames',{'ani1','ani2','ani3','ani4'});
Meas = table([1 2 3 4]','VariableNames',{'Animals'});

rm = fitrm(t,'ani1-ani4~1','WithinDesign',Meas);
ranova(rm);


% two-way repeated measures ANOVA
% https://www.discoveringstatistics.com/repository/repeatedmeasures.pdf

% https://books.google.de/books?id=AlNdBAAAQBAJ&pg=PA594&lpg=PA594&dq=Female+LooksOrPersonality.sav&source=bl&ots=mX9jBs6wZ6&sig=h5Ng0iaj-XtZibbI4Pie9TkRHeA&hl=en&sa=X&ved=0ahUKEwja--OV4eXVAhVCthoKHTM7Cy0Q6AEILjAB#v=onepage&q=Female%20LooksOrPersonality.sav&f=false
% Gender att_high av_high ug_high att_some av_some ug_some att_none av_none ug_none
% male/female
r = [
1	86	84	67	88	69	50	97	48	47
1	91	83	53	83	74	48	86	50	46
1	89	88	48	99	70	48	90	45	48
1	89	69	58	86	77	40	87	47	53
1	80	81	57	88	71	50	82	50	45
1	80	84	51	96	63	42	92	48	43
1	89	85	61	87	79	44	86	50	45
1	100	94	56	86	71	54	84	54	47
1	90	74	54	92	71	58	78	38	45
1	89	86	63	80	73	49	91	48	39
2	89	91	93	88	65	54	55	48	52
2	84	90	85	95	70	60	50	44	45
2	99	100	89	80	79	53	51	48	44
2	86	89	83	86	74	58	52	48	47
2	89	87	80	83	74	43	58	50	48
2	80	81	79	86	59	47	51	47	40
2	82	92	85	81	66	47	50	45	47
2	97	69	87	95	72	51	45	48	46
2	95	92	90	98	64	53	54	53	45
2	95	93	96	79	66	46	52	39	47
];

% Y = r(1:10,2:10); % only males
Y = r(11:20,2:10); % only females (in the example in http://www.discoveringstatistics.com/docs/repeatedmeasures.pdf, page 12)

F1 = repmat([
1	2	3	1	2	3	1	2	3],10,1);

F2 = repmat([
1	1	1	2	2	2	3	3	3],10,1);

S = [repmat([1:10],9,1)']; % subjects
% S = [repmat([1:10],9,1)' ; repmat([1:10],9,1)']; % subjects for both genders

% matches http://www.discoveringstatistics.com/docs/repeatedmeasures.pdf, page 12
stats = rm_anova2(reshape(Y,10*9,1),reshape(S,10*9,1),reshape(F1,10*9,1),reshape(F2,10*9,1),{'looks','charisma'}) 

% https://stats.stackexchange.com/questions/46735/how-to-assign-degrees-of-freedom-for-two-way-anova-with-two-within-subjects-fact
% df for the two-way, factorial, within-subjects factors ANOVA
%     A = a - 1, where a = number of levels of A
%     B = b - 1, where b = number of levels of B
%     A x B = (a - 1)(b - 1)
%     S = n - 1, where s = number of levels of S (i.e., number of subjects)
%     A x S = (a - 1)(n - 1)
%     B x S = (b - 1)(n - 1)
%     A x B x S = (a - 1)(b - 1)(n - 1)

% Repeated measures via fitrm
% http://compneurosci.com/wiki/images/e/e6/Repeated_ANOVA_MATLAB_v2.pdf
% same data from http://www.discoveringstatistics.com/docs/LooksOrPersonality.dat
T = readtable('testsim_repeated_measures_anova_LooksOrPersonality.dat','Delimiter','\t');
% but we need it in a different format:

% Rating = reshape(Y,10*9,1);
% Subject = reshape(S,10*9,1);
% Looks = reshape(F1,10*9,1);
% Charisma = reshape(F2,10*9,1);
% T1 = table(Subject,Rating,Looks,Charisma);

between = table(Y(:,1),Y(:,2),Y(:,3),Y(:,4),Y(:,5),Y(:,6),Y(:,7),Y(:,8),Y(:,9),...
'VariableNames',{'att_high', 'av_high', 'ug_high', 'att_some', 'av_some', 'ug_some', 'att_none', 'av_none', 'ug_none'});

within = table(['1'	'2'	'3'	'1'	'2'	'3'	'1'	'2'	'3']',['1' '1' '1' '2' '2' '2' '3' '3' '3']','VariableNames',{'Looks','Charisma'}); 
% within = table([1 2 3 1 2 3 1 2 3]',[1 1 1 2 2 2 3 3 3]','VariableNames',{'Looks','Charisma'}); % NOT WORKING!
%!!! very important !!! to define within factors as 'categorical'! otherwise (if numeric, [1 2 3]), the results don't make sense

rm = fitrm(between,'att_high,av_high,ug_high,att_some,av_some,ug_some,att_none,av_none,ug_none ~ 1','WithinDesign',within);
% ranovatbl = ranova(rm)
ranovatbl = ranova(rm,'WithinModel','Looks*Charisma')



