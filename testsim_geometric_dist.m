% testsim_geometric_dist
% http://en.wikipedia.org/wiki/Geometric_distribution
% http://mathworld.wolfram.com/GeometricDistribution.html
% http://www.mathworks.com/help/stats/geometric-distribution.html

% Some theory:
% The geometric distribution is the only discrete memoryless random distribution. 
% It is a discrete analog of the exponential distribution. 
% P(n,p) = p*(1 - p)^n, where 
% p is the probability of success
% n is the number of failures before the first success
% or interval duration!
% P is the probability of observing exactly n trials before a success, 
% when the probability of success in any given trial is p.

% The mean of the geometric distribution, E = (1 - p)/p
% from this follows that p = 1/(E + 1)

% If P is the probability that the interval between events would be equal
% to n, then an ideal observer would not be able to anticipate the event
% occurence - the probability that the event is about to happen now would
% be the same regardless of elapsed time - it is p! For this reason, the 
% geometric and exponential distributions are used in experiments where
% anticipation is not desirable.

% For comparison, if intervals are drawn from uniform distribution, then an
% ideal observer would know that as time elapses, the probability of "event
% occuring now" is increasing gradulally.





% Examples: 

% 1. Specify p, then estimate p using 1000 iterations
p = 0.75
n_samples = 1000;


for i = 1:1000, % n iterations
	m(i) = mean(geornd(p,1,n_samples));
end

E = mean(m); % mean of means
p_estimated = 1 / (E + 1)


% 2. Specify mean (E), get p and sequences

E = 3; % mean

p = 1 / (E + 1);

seq = geornd(p,1,1000);
mean(seq);

hist(seq);

title(sprintf('mean %.2f p %.2f est. mean %.2f ',E,p,mean(seq))); 




