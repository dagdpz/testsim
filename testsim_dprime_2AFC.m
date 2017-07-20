function [d,beta] = testsim_dprime_2AFC(sequence)
% d' 2AFC
% e.g. large/small reward
% Question - is large reward on the right?
% small [large] hit (1)
% [small] large miss (2)
% large [small] false alarm (3)
% [large] small correct rejection (4)

% pHit: Hit Rate = Hits / (Hits + Misses)
% pFA:	False Alarm Rate = False Alarms / (False Alarms + Correct Rejections)


Hits			= sum(sequence == 1);
Misses			= sum(sequence == 2);
FalseAlarms		= sum(sequence == 3);
CorrectRejections	= sum(sequence == 4);

pHit = Hits / (Hits + Misses);
pFA = FalseAlarms / (FalseAlarms + CorrectRejections);

[d,beta] = testsim_dprime(pHit,pFA);


