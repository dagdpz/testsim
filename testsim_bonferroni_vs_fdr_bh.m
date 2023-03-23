function testsim_bonferroni_vs_fdr_bh

n1 = 3000;
n2 = 100;

n_obs = 100;

nullVars=randn(n_obs,n1);
[hh, p_null]=ttest(nullVars); %n1 tests where the null hypothesis is true
effectVars=randn(n_obs,n2)+0.7;
[hh, p_effect]=ttest(effectVars); %n2 tests where the null hypothesis is false
p_null
p_effect


h_bonf = ([p_null p_effect]) <0.05/(n1+n2);
disp(sprintf('Out of %d tests, %d are significant using Bonferroni',n1+n2,sum(h_bonf)));


[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh([p_null p_effect],.05,'pdep','yes');

% data=[nullVars effectVars];
% fcr_adj_cis=NaN*zeros(2,20); %initialize confidence interval bounds to NaN
% if ~isnan(adj_ci_cvrg),
%         sigIds=find(h);
%         fcr_adj_cis(:,sigIds)=tCIs(data(:,sigIds),adj_ci_cvrg); % tCIs.m is available on the
%         %Mathworks File Exchagne
% end