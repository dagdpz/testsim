% testsim_manova1

N = 100;

Noise1 = [5 5];
Noise2 = [5 5];
Noise3 = [5 5];

x1 = 0 + Noise1(1)*randn(N,1);
y1 = 0 + Noise1(2)*randn(N,1);

x2 = 10 + Noise2(1)*randn(N,1);
y2 = 0 + Noise2(2)*randn(N,1);

x3 = 20 + Noise3(1)*randn(N,1);
y3 = 0 + Noise3(2)*randn(N,1);


figure;
plot(x1,y1,'r.'); hold on;
plot(x2,y2,'g.'); hold on;
plot(x3,y3,'b.'); hold on;

[D, p] = manova1([[x1;x2;x3] [y1;y2;y3]],[1*ones(N,1); 2*ones(N,1); 3*ones(N,1)])