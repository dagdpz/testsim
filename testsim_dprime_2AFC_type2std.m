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

rating_scale = [1 2 3 4 5 6];
nRatings	= length(rating_scale);

% random performance and certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= randsample([0 1],60,1);
rating		= randsample(rating_scale,60,1);

% good performance, random certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= [zeros(1,25) ones(1,5) ones(1,25) zeros(1,5)];
rating		= randsample(rating_scale,60,1);

% good performance, good certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= [zeros(1,25) ones(1,5) ones(1,25) zeros(1,5)];
rating		= [randsample(rating_scale,25,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample(rating_scale,5,1,[0.3 0.2 0.2 0.15 0.1 0.05])...
		   randsample(rating_scale,25,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample(rating_scale,5,1,[0.3 0.2 0.2 0.15 0.1 0.05])];
	   
% bad performance, good certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= [zeros(1,18) ones(1,12) ones(1,18) zeros(1,12)];
rating		= [randsample(rating_scale,18,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample(rating_scale,12,1,[0.3 0.2 0.2 0.15 0.1 0.05])...
		   randsample(rating_scale,18,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample(rating_scale,12,1,[0.3 0.2 0.2 0.15 0.1 0.05])];


% good performance, almost optimal certainty rating
stimID		= [zeros(1,30) ones(1,30)];
response	= [zeros(1,25) ones(1,5) ones(1,25) zeros(1,5)];
rating		= [randsample(rating_scale,25,1,[0.025 0.025 0.025 0.025 0.05 0.85]) randsample(rating_scale,5,1,[0.85 0.05 0.025 0.025 0.025 0.025])...
		   randsample(rating_scale,25,1,[0.025 0.025 0.025 0.025 0.05 0.85]) randsample(rating_scale,5,1,[0.85 0.05 0.025 0.025 0.025 0.025])];

% good performance for S1 but not so good for S2, good certainty rating
stimID		= [zeros(1,150) ones(1,150)];
response	= [zeros(1,148) ones(1,2) ones(1,100) zeros(1,50)];
rating		= [randsample(rating_scale,148,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample(rating_scale,2,1,[0.3 0.2 0.2 0.15 0.1 0.05])...
		   randsample(rating_scale,100,1,[0.05 0.1 0.15 0.2 0.2 0.3]) randsample(rating_scale,50,1,[0.3 0.2 0.2 0.15 0.1 0.05])];
	   
% good performance for S1 but not so good for S2, not good certainty rating - like Data_CIKO231_2019-01-16_01.mat
% stimID		= [zeros(1,150) ones(1,149)];
% response	= [zeros(1,147) ones(1,3) ones(1,106) zeros(1,43)];
% rating		= [randsample(rating_scale,147,1,[0.0136         0    0.0476    0.0680    0.4898    0.3810]) randsample(rating_scale,3,1,[0    0.3333    0.6667         0         0         0])...
% 		   randsample(rating_scale,106,1,[0.0094    0.0189    0.0566    0.1226    0.5660    0.2264]) randsample(rating_scale,43,1,[ 0         0    0.1628    0.1628    0.5581    0.1163])];


% good performance for S2 but not so good for S1, not good certainty rating - ***reverse*** to Data_CIKO231_2019-01-16_01.mat
stimID		= [zeros(1,149) ones(1,150)];
response	= [zeros(1,106) ones(1,43) ones(1,147) zeros(1,3)];
rating		= [randsample(rating_scale,106,1,[0.0094    0.0189    0.0566    0.1226    0.5660    0.2264]) randsample(rating_scale,43,1,[ 0         0    0.1628    0.1628    0.5581    0.1163])...
		   randsample(rating_scale,147,1,[0.0136         0    0.0476    0.0680    0.4898    0.3810]) randsample(rating_scale,3,1,[0    0.3333    0.6667         0         0         0])];


% CIKO023
% left S1, right S2
% load('Data_CIKO231_2019-01-16_01.mat');
% idx_completed	= find(stimID==0 | stimID==1);
% stimID		= stimID(idx_completed);
% response	= response(idx_completed);
% rating		= rating(idx_completed);
% [C,I] = calclulate_rating_specific_prop(stimID,response,rating,rating_scale,1)

% Data_SIGO031_2019-01-17_01.mat 
% left S1, right S2
load('Data_SIGO031_2019-01-17_01.mat');
idx_completed	= find(stimID==1 | stimID==1);
stimID		= stimID(idx_completed);
response	= response(idx_completed);
rating		= rating(idx_completed);
[C,I] = calclulate_rating_specific_prop(stimID,response,rating,rating_scale,1)
	   
[nR_S1, nR_S2] = trials2counts(stimID, response, rating, nRatings,0,0);

% basic d'
% the question has to be reformulated from "is there S1 or S2?" to "is there S1?"

Hits			= sum(stimID == 0 & response == 0);
Misses			= sum(stimID == 0 & response == 1);
FalseAlarms		= sum(stimID == 1 & response == 0);
CorrectRejections	= sum(stimID == 1 & response == 1);

pHit = Hits / (Hits + Misses);
pFA = FalseAlarms / (FalseAlarms + CorrectRejections);

[d_prime,beta] = testsim_dprime(pHit,pFA)

out = type2_SDT_SSE(nR_S1, nR_S2)

testsim_rocCurve_confidence(rating, stimID==response, 1);

figure
[X_FPR,Y_TPR,T,AUC] = perfcurve(stimID==response,rating,true);
plot(X_FPR,Y_TPR);
xlabel('False positive rate'); ylabel('True positive rate')
title(sprintf('ROC by perfcurve, AUC %.2f',AUC));
 


function [C,I] = calclulate_rating_specific_prop(stimID,response,rating,rating_scale,TOPLOT)
nRatings	= length(rating_scale);

idx_cor = find(stimID==response);
idx_inc = find(stimID~=response);

n_cor = length(idx_cor);
n_inc = length(idx_inc);

for r = 1:nRatings,
	idx_r = find(rating == rating_scale(r));
	C(r) = length(intersect(idx_r,idx_cor));
	I(r) = length(intersect(idx_r,idx_inc));
end

C = C/n_cor;
I = I/n_inc;

if TOPLOT
	figure;
	plot(rating_scale,C,'g-o'); hold on
	plot(rating_scale,I,'r-o'); hold on
	xlabel('rating');
	ylabel('rating-specific prop');
	title(sprintf('%d trials, %d cor, %d inc, perf. %.2f',length(stimID),n_cor,n_inc,n_cor/length(stimID)));
end










