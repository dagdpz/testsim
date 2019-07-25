function [d,beta,c] = testsim_dprime_2AFC(sequence)
% d' 2AFC
% e.g. large/small reward
% Question - is large reward on the right?
% small [large] hit (1)
% [small] large miss (2)
% large [small] false alarm (3)
% [large] small correct rejection (4)

% pHit: Hit Rate = Hits / (Hits + Misses)
% pFA:	False Alarm Rate = False Alarms / (False Alarms + Correct Rejections)

if nargin < 1,
    % set some performance here
    Hits                = 10;
    Misses              = 5;
    FalseAlarms         = 4;
    CorrectRejections   = 6;
    
    
else
    
    Hits			= sum(sequence == 1);
    Misses			= sum(sequence == 2);
    FalseAlarms		= sum(sequence == 3);
    CorrectRejections	= sum(sequence == 4);

end

pHit = Hits / (Hits + Misses);
pFA = FalseAlarms / (FalseAlarms + CorrectRejections);

[d,beta,c] = testsim_dprime(pHit,pFA);

% from https://psychology.stackexchange.com/questions/17188/calculation-of-dprime-in-forced-choice-experiment
% The two most common paradigms with exactly two response choices are typically called the yes/no paradigm and the 2AFC paradigm. 
% Despite it's name, the yes/no paradigm can have any response labels, including left arrow and right arrow. 
% In the typical setup, in addition to both paradigm having 2 responses, both paradigms have exactly two stimulus classes (e.g., signal and noise). 
% The defining characteristic that differentiates a yes/no paradigm from a 2AFC paradigm is that in a yes/no paradigm each trial (and hence response) is based on a single presentation of one of the stimulus classes,
% while in the 2AFc paradigm there is a single presentation of both stimuli classes (either concurrently or sequentially). 
% This difference is critical for calculating d? and a ?2/2 scale factor is needed to correct for the fact that in the 2AFC paradigm there is more information.
%
% See testsim_dprime for the references in regards to yes/no vs. 2AFC 



