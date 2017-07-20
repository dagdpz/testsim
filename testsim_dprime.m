function [d,beta] = testsim_dprime(pHit,pFA)
% pHit	- hit probability
% pFA	- probability of False Alarms
% http://en.wikipedia.org/wiki/D%27

% Convert to Z scores
zHit = norminv(pHit);
zFA  = norminv(pFA);

% Calculate d-prime
d = zHit - zFA;

% Calculate BETA (the criterion value)
if (nargout > 1)
	yHit = normpdf(zHit);
	yFA  = normpdf(zFA);
	beta = yHit ./ yFA;
end
