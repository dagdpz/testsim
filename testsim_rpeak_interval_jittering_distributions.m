a=3; b=2;
x=-20:20;
N=10000;

gammadistribution =gamrnd(a,b,1,N);
gamhist=hist(gammadistribution,x);

jittered_distribution=gammadistribution+randn(1,N)*std(gammadistribution);
jittered_hist=hist(jittered_distribution,x);

figure
hold on;
plot(x,gamhist)
plot(x,jittered_hist)
