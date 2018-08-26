function testsim_z_score
% test z-score

% s = [1 + 2*randn(1,100)]; % mean 1, SD 2
s = [1 + 2*randn(1,100) 2 + 3*randn(1,100)]; 

zs1 = zscore(s); % MATLAB or NaN toolbox -- difference in dim argument (cf. std)!!! NOTE: MATLAB zscore does not deal with NaNs!
zs2 = z_score(s); % just to make sure they are the same

subplot(2,1,1);
plot(s);
title(sprintf('mean %.2f SD %.2f',mean(s),std(s)));

subplot(2,1,2);

plot(zs1,'r'); hold on
plot(zs2,'g:');
title(sprintf('Z-scored signal: mean %.2f SD %.2f',mean(zs1),std(zs1)));



function z = z_score(s)

z = (s - mean(s))./std(s);


