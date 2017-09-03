% testsim_chi_square
% test Chi-square
% http://sphweb.bumc.bu.edu/otlt/MPH-Modules/BS/BS704_HypothesisTesting-ChiSquare/BS704_HypothesisTesting-ChiSquare2.html
% http://www.socscistatistics.com/tests/goodnessoffit/Default2.aspx

% Example 1: 3 discrete outcomes (see links above)
disp('Example 1: 3 discrete outcomes')
[h,p,st] = chi2gof([1 2 3],'ctrs',[1 2 3],'frequency',[255 125 90],'expected',[282 117.5 70.5],'nparams',0)
% degrees of freedom = to nbins - 1 - nparams, in this example df = 2


% Example 2: chi-square vs fexact, on two outcomes
disp('Example 2: chi-square vs fexact, on two outcomes')
[h,p,st] = chi2gof([1 2],'ctrs',[1 2],'frequency',[25 75],'expected',[50 50],'nparams',0)


% Fisher's exact
% see also testsim_fexact.m
Ns1 = 100; % condition, or status 1 (e.g. control): HERE expected
Ns2 = 100; % condition, or status 2 (e.g. stimulation): HERE observed
 
% Let's assign arbitrary outcome 2 ("1") as "success"
p_suc1 = 0.5; % probability success in status 1
p_suc2 = 0.75; % probability success in status 2
 
y1 = zeros(1,Ns1);	
y2 = ones(1,Ns2);	
 
x1 = [zeros(1,round(  (1-p_suc1)*Ns1 )) ones( 1, round(p_suc1*Ns1) )];	% status 1 outcome 
x2 = [zeros(1,round(  (1-p_suc2)*Ns2 )) ones( 1, round(p_suc2*Ns2) )];	% status 2 outcome 
 
p = fexact( [x1 x2]' , [y1 y2]' )

% Example 3: 2x2 using crosstab vs. chi-square test 
% https://de.mathworks.com/matlabcentral/answers/96572-how-can-i-perform-a-chi-square-test-to-determine-how-statistically-different-two-proportions-are-in
% same result as from http://www.socscistatistics.com/tests/chisquare/Default2.aspx
disp('Example 3: 2x2 using crosstab vs. chi-square test')

A1 = 51; A2 = 8142; % condition A, two outcomes
B1 = 74; B2 = 8127; % condition B, two outcomes

x1 = [repmat('a',A1+A2,1); repmat('b',B1+B2,1)]; % condition A or condition B
x2 = [repmat(1,A1,1); repmat(2,A2,1); repmat(1,B1,1); repmat(2,B2,1)];

[tbl,chi2stat,pval] = crosstab(x1,x2)

% Now using chi2gof as in example 1

% Pooled estimate of proportion
NA = A1 + A2;
NB = B1 + B2;
p0 = (A1+B1) / (NA + NB);

% Expected counts under H0 (null hypothesis)
NA0 = NA * p0;
NB0 = NB * p0;

% Chi-square test, by hand
observed = [A1 A2 B1 B2];
expected = [NA0 NA-NA0 NB0 NB-NB0];

[h,p,stats] = chi2gof([1 2 3 4],'freq',observed,'expected',expected,'ctrs',[1 2 3 4],'nparams',0) % NOTE: with nparams=0, the p-value is the same as in
% http://www.socscistatistics.com/tests/goodnessoffit/Default2.aspx

% degrees of freedom = to nbins - 1 - nparams
% But if nparams = 2 (df=4-2-1=1), the p-value is correct
[h,p,stats] = chi2gof([1 2 3 4],'freq',observed,'expected',expected,'ctrs',[1 2 3 4],'nparams',2) 

