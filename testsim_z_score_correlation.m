function testsim_z_score_correlation

v1s1 = 0 + 2*randn(1,20);
v2s1 = v1s1 + 1*randn(1,20);

v1s2 = 5 + 2*randn(1,20);
v2s2 = v1s2 + 1*randn(1,20);

plot([v1s1 v1s2],'ro'); hold on
plot([v2s1 v2s2],'bo'); hold on


disp('no zscore')
[r,p]=corrcoef([v1s1 v1s2],[v2s1 v2s2])

disp('zscore per session')
[r,p]=corrcoef([zscore(v1s1) zscore(v1s2)],[zscore(v2s1) zscore(v2s2)])

disp('zscore across sessions')
[r,p]=corrcoef(zscore([v1s1 v1s2]),zscore([v2s1 v2s2]))