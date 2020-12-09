% testsim_uniform_circular_dist

for k = 1:1000,
    a = 259*rand(1,100000);
    ma(k) = mean(a);
end

N = 1000;
x = 0;
y = 0;
r = 1;

Ns = round(1.28*N + 2.5*sqrt(N) + 100); % 4/pi = 1.2732
X = rand(Ns,1)*(2*r) - r;
Y = rand(Ns,1)*(2*r) - r;
I = find(sqrt(X.^2 + Y.^2)<=r);
X = X(I(1:N)) + x;
Y = Y(I(1:N)) + y;
[TH,R] = cart2pol(X,Y);
% A = atan2d(Y,X);

X1 = cos(TH);
Y1 = sin(TH);

plot(X,Y,'.r')