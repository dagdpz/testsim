function [out] = testsim_rocCurve_confidence(score, trueLabel, doPlot)
% Plot a receiver operating curve, as function of confidence score
% function [faRate, hitRate, AUC] = rocCurve_conf(score, trueLabel, doPlot)
%
% score(i) = confidence in i'th detection (bigger means more confident)
% trueLabel(i) = 0 if no signal (e.g. no match) or 1 if signal (match)
% doPlot - optional (default 1)
%
% faRate(t) = false alarm rate at t'th threshold
% hitRate(t) = detection rate at t'th threshold
% AUC = area under curve (should be from 0.5 (d'=0) to 1)
% Example: random rating on random performance
% out = testsim_rocCurve_confidence(ceil((rand(1,100)*6)), floor((rand(1,100)*2)), 1)


% This file is originally from https://github.com/probml/pmtk3/blob/master/matlabTools/stats/ROCcurve.m
% modified by Igor Kagan, 2014
% for more info, see:
% http://en.wikipedia.org/wiki/Receiver_operating_characteristic
% http://www-psych.stanford.edu/~lera/psych115s/notes/signal/
% http://www.mbfys.ru.nl/~robvdw/DGCN22/PRACTICUM_2011/LABS_2011/ALTERNATIVE_LABS/lessons.html
% http://www.mbfys.ru.nl/~robvdw/DGCN22/PRACTICUM_2011/LABS_2011/ALTERNATIVE_LABS/Lesson_9.html

if nargin < 3, doPlot = 0; end

class1 = find(trueLabel==1);
class0 = find(trueLabel==0);

thresh = unique(sort(score));
Nthresh = length(thresh);
hitRate = zeros(1, Nthresh);
faRate = zeros(1, Nthresh);
for thi=1:length(thresh)
	th = thresh(thi);
	% hit rate = TP/P
	hitRate(thi) = sum(score(class1) >= th) / length(class1);
	% fa rate = FP/N
	faRate(thi) = sum(score(class0) >= th) / length(class0);
end
% AUC = sum(abs(faRate(2:end) - faRate(1:end-1)) .* hitRate(2:end)); original formula
AUC = -trapz(faRate,hitRate); % more precise formula

d_prime = testsim_dprime(hitRate,faRate);
out.hitRate = hitRate;
out.faRate = faRate;
out.AUC = AUC;
out.d_prime = d_prime;

if ~doPlot, return; end
figure;
plot([faRate 0], [hitRate 0], '-');
e = 0.05; axis([0-e 1+e 0-e 1+e])
xlabel('false alarm rate')
ylabel('hit rate')
line([0 1],[0 1],'Color',[1 0 0])
grid on
title(sprintf('AUC=%5.3f', AUC))
axis square
