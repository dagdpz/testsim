function testsim_z_score_normalization
% test z-score normalization

if 0 % variant 1: one task, one condition, two epochs: baseline and response, same noise
n_trials = 50;
n_samples = 200;
baseline_amp = 2;
response_amp = 10;
noise_baseline = 5; % the more is noise, the smaller is the z-score
noise_response = 5;
s = [baseline_amp + noise_baseline*randn(n_trials,n_samples/2) response_amp + noise_response*randn(n_trials,n_samples/2)]; 
idx_b = 1:n_samples/2;
idx_r = n_samples/2+1:n_samples;

zs = zscore(reshape(s,n_trials*n_samples,1)); % concatenated 

mean_zs = mean(zs);
std_zs = std(zs);
zs = reshape(zs,n_trials,n_samples);
mean_s = mean(s,1);
subplot(2,1,1);
plot(s'); hold on
plot(mean_s,'k','LineWidth',3); hold on
title(sprintf('original signal'));
grid on


subplot(2,1,2);
plot(mean(zs,1),'r'); hold on
title(sprintf('Z-scored signal: mean %.2f SD %.2f',mean_zs,std_zs));
grid on

elseif 1 % one task, two "conditions" (e.g. pre- and post-injection, or two tasks), three epochs: "baseline" "response1" "response2"
	
% condition 1
n_trials1 = 50;
n_samples1 = 300;
amp1(1) = 2; % baseline
amp1(2) = 10; % response 1
amp1(3) = 15; % response 2
noise1(1) = 3; % the more is noise, the smaller is the z-score
noise1(2) = 3;
noise1(3) = 3;

% condition 2
n_trials2 = 25;
n_samples2 = n_samples1;
amp2(1) = 2;
amp2(2) = 10;
amp2(3) = 25;
noise2(1) = 3; % the more is noise, the smaller is the z-score
noise2(2) = 3;
noise2(3) = 3;

s1 = [amp1(1) + noise1(1)*randn(n_trials1,n_samples1/3) amp1(2) + noise1(2)*randn(n_trials1,n_samples1/3) amp1(3) + noise1(3)*randn(n_trials1,n_samples1/3)]; 
zs1 = zscore(reshape(s1,n_trials1*n_samples1,1)); % concatenated trials
mean_zs1 = mean(zs1);
std_zs1 = std(zs1);
zs1 = reshape(zs1,n_trials1,n_samples1);
mean_s1 = mean(s1,1);

s2 = [amp2(1) + noise2(1)*randn(n_trials2,n_samples2/3) amp2(2) + noise2(2)*randn(n_trials2,n_samples2/3) amp2(3) + noise2(3)*randn(n_trials2,n_samples2/3)]; 
% zs2 = zscore(reshape(s2,n_trials2*n_samples2,1)); % concatenated trials
% condition 2 is zscored using mean and std of condition 1!
zs2 = (reshape(s2,n_trials2*n_samples2,1) - mean(reshape(s1,n_trials1*n_samples2,1)))/std(reshape(s1,n_trials1*n_samples2,1)); 
mean_zs2 = mean(zs2);
std_zs2 = std(zs2);
zs2 = reshape(zs2,n_trials2,n_samples2);
mean_s2 = mean(s2,1);	

% Difference between two conditions
d = mean(s2,1) - mean(s1,1); % raw signal
dz = mean(zs2,1) - mean(zs1,1); % z-scored

for k = 1:n_samples1,
	Cohen_d(k) = computeCohen_d(s2(:,k), s1(:,k)); 
	Cohen_dz(k) = computeCohen_d(zs2(:,k), zs1(:,k)); 
	
	% calculate sample by sample significance on raw data
	[hs(k),ps(k)] = ttest2(s1(:,k),s2(:,k));
	
	% calculate sample by sample significance on zscored data
	[hz(k),pz(k)] = ttest2(zs1(:,k),zs2(:,k));	
	
end

hs_fdr = fdr_bh(ps);
hz_fdr = fdr_bh(pz);

t = 1:n_samples1;

figure('Position',[100 100 1200 400]);
subplot(2,4,1);
plot(s1'); hold on
plot(mean_s1,'k','LineWidth',3); hold on
title(sprintf('s1 base resp1 resp2  %s',num2str(amp1)));
grid on

subplot(2,4,5);
plot(mean(zs1,1),'k'); hold on
title(sprintf('Z-scored s1: mean %.2f SD %.2f',mean_zs1,std_zs1));
grid on

subplot(2,4,2);
plot(s2'); hold on
plot(mean_s2,'k','LineWidth',3); hold on
title(sprintf('s2 base resp1 resp2  %s',num2str(amp2)));
grid on

subplot(2,4,6);
plot(mean(zs2,1),'k'); hold on
title(sprintf('Z-scored s2: mean %.2f SD %.2f',mean_zs2,std_zs2));
grid on

subplot(2,4,3);
plot(t,d,'k','LineWidth',1); hold on
plot(t(hs==1),d(hs==1),'r.');
plot(t(hs_fdr==1),d(hs_fdr==1),'ro');
title(sprintf('s2 - s1'));
grid on

subplot(2,4,7);
plot(t,dz,'k','LineWidth',1); hold on
plot(t(hz==1),dz(hz==1),'r.');
plot(t(hz_fdr==1),dz(hz_fdr==1),'ro');
title(sprintf('zs 2 - zs 1'));
grid on

subplot(2,4,4);
plot(t,Cohen_d,'k','LineWidth',1); hold on
title(sprintf('Cohen d'));
grid on

subplot(2,4,8);
plot(t,Cohen_dz,'k','LineWidth',1); hold on
title(sprintf('Cohen d on z-scored'));
grid on


end