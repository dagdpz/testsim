function testsim_dprime_2AFC_type2std
% d' 2AFC and meta-d', using http://www.columbia.edu/~bsm2105/type2sdt/
% uses type2sdt 

% % INPUTS
% stimID:   1xN vector. stimID(i) = 0 --> stimulus on i'th trial was S1.
%                       stimID(i) = 1 --> stimulus on i'th trial was S2.
%
% response: 1xN vector. response(i) = 0 --> response on i'th trial was "S1".
%                       response(i) = 1 --> response on i'th trial was "S2".
%
% rating:   1xN vector. rating(i) = X --> rating on i'th trial was X.
%                       X must be in the range 1 <= X <= nRatings.

% random performance and certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= randsample([0 1],60,1);
rating		= randsample([1 2 3 4 5 6],60,1);
nRatings	= length(unique(rating));

% good performance, random certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= [zeros(1,25) ones(1,5) ones(1,25) zeros(1,5)];
rating		= randsample([1 2 3 4 5 6],60,1);
nRatings	= length(unique(rating));

% good performance, good certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= [zeros(1,25) ones(1,5) ones(1,25) zeros(1,5)];
rating		= [randsample([1 2 3 4 5 6],25,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample([1 2 3 4 5 6],5,1,[0.3 0.2 0.2 0.15 0.1 0.05])...
		   randsample([1 2 3 4 5 6],25,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample([1 2 3 4 5 6],5,1,[0.3 0.2 0.2 0.15 0.1 0.05])];
nRatings	= length(unique(rating));

[nR_S1, nR_S2] = trials2counts(stimID, response, rating, nRatings);

% basic d'
% the question has to be reformulated from "is there S1 or S2?" to "is there S1?"

Hits			= sum(stimID == 0 & response == 0);
Misses			= sum(stimID == 0 & response == 1);
FalseAlarms		= sum(stimID == 1 & response == 0);
CorrectRejections	= sum(stimID == 1 & response == 1);

pHit = Hits / (Hits + Misses);
pFA = FalseAlarms / (FalseAlarms + CorrectRejections);

[d,beta] = testsim_dprime(pHit,pFA)

out = type2_SDT_SSE(nR_S1, nR_S2)

testsim_rocCurve_confidence(rating, stimID==response, 1);





