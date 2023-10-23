% This simulation is created to study distribution changes in the jittering
% procedure implemented in ecg_bna repo.
%
% GAMMADISTRIBUTION - simulates a skewed distribution of RR-intervals in
% ECG
% JITTERED_DISTRIBUTION - shows what happens to the original distribution
% after jittering
%

k=3; theta=2; % parameters of a gamma distribution: k - shape parameter, theta - scale parameter
x=-20:20; % bins
N=10000; % sample size

gammadistribution =gamrnd(k,theta,1,N);
gamhist=hist(gammadistribution,x);

jittered_distribution=gammadistribution+randn(1,N)*std(gammadistribution);
jittered_hist=hist(jittered_distribution,x);

figure
hold on;
plot(x,gamhist)
plot(x,jittered_hist)
legend({'Original Distribution', 'Jittered Distribution'})