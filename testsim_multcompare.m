% testsim_multcompare

g1 = rand(1,10)';
g2 = 0.5+rand(1,10)';
g3 = rand(1,10)';

[h12,p12] = ttest2(g1,g2)
[h13,p13] = ttest2(g1,g3)
[h23,p23] = ttest2(g2,g3)

[p,table,stats,terms] = anovan([g1;g2;g3],[1*ones(1,10)'; 2*ones(1,10)'; 3*ones(1,10)'],'model','full','display',0)
[c,m,h] = multcompare(stats,'dimension',1,'alpha',0.05)

ch = ig_get_multicompare_significance(c)

% check that multcompare is ttest2 when only two groups
% [p,table,stats,terms] = anovan([g1;g2],[1*ones(1,10)'; 2*ones(1,10)'],'model','full','display',0)
% [c,m,h] = multcompare(stats,'dimension',1,'alpha',p12)


% [p,table,stats] = anova1([g1;g2;g3],[1*ones(1,10)'; 2*ones(1,10)'; 3*ones(1,10)']);
% [c,m,h] = multcompare(stats)
% dunnett(stats)

% holm([data_t data_t_group'],1)