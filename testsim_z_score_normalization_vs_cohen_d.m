function testsim_z_score_normalization_vs_cohen_d
% compare z-score normalization and Cohen's d
% note: for unequal sample sizes (n_trials), computeCohen_d is Hedges' g
% http://www.socscistatistics.com/effectsize/Default3.aspx
% uses computeCohen_d from Igtools/external


% variant 1: one task, two conditions (e.g. pre- and post-injection), two epochs: "baseline" and "response"

% condition 1
n_trials1 = 50;
n_samples = 200;
baseline_amp1 = 2;
response_amp1 = 10;
noise_baseline1 = 3; % the more is noise, the smaller is the z-score
noise_response1 = 3;

% condition 2
n_trials2 = 25;
n_samples2 = 200;
baseline_amp2 = 2;
response_amp2 = 8;
noise_baseline2 = 3; % the more is noise, the smaller is the z-score
noise_response2 = 3;


s1 = [baseline_amp1 + noise_baseline1*randn(n_trials1,n_samples/2) response_amp1 + noise_response1*randn(n_trials1,n_samples/2)]; 
idx_b1 = 1:n_samples/2;
idx_r1 = n_samples/2+1:n_samples;
zs1 = zscore(reshape(s1,n_trials1*n_samples,1)); % concatenated trials
mean_zs1 = mean(zs1);
std_zs1 = std(zs1);
zs1 = reshape(zs1,n_trials1,n_samples);
mean_s1 = mean(s1,1);

s2 = [baseline_amp2 + noise_baseline2*randn(n_trials2,n_samples2/2) response_amp2 + noise_response2*randn(n_trials2,n_samples2/2)]; 
idx_b2 = 1:n_samples2/2;
idx_r2 = n_samples2/2+1:n_samples2;
% zs2 = zscore(reshape(s2,n_trials2*n_samples2,1)); % concatenated trials
% condition 2 is zscored using mean and std of condition 1!
zs2 = (reshape(s2,n_trials2*n_samples2,1) - mean(reshape(s1,n_trials1*n_samples,1)))/std(reshape(s1,n_trials1*n_samples,1)); 
mean_zs2 = mean(zs2);
std_zs2 = std(zs2);
zs2 = reshape(zs2,n_trials2,n_samples);
mean_s2 = mean(s2,1);

% Difference between two conditions
d = mean(s2,1) - mean(s1,1); % raw signal
dz = mean(zs2,1) - mean(zs1,1); % z-scored

for k = 1:n_samples,
	Cohen_d(k) = computeCohen_d(s2(:,k), s1(:,k)); 
	Cohen_dz(k) = computeCohen_d(zs2(:,k), zs1(:,k)); 
	
	% calculate sample by sample significance on raw data
	[hs(k),ps(k)] = ttest2(s1(:,k),s2(:,k));
	
	% calculate sample by sample significance on zscored data
	[hz(k),pz(k)] = ttest2(zs1(:,k),zs2(:,k));	
	
end

hs_fdr = fdr_bh(ps);
hz_fdr = fdr_bh(pz);


t = 1:n_samples;

figure('Position',[100 100 1200 400]);
subplot(2,4,1);
plot(s1'); hold on
plot(mean_s1,'k','LineWidth',3); hold on
title(sprintf('original signal 1'));
grid on

subplot(2,4,5);
plot(mean(zs1,1),'k'); hold on
title(sprintf('Z-scored s1: mean %.2f SD %.2f',mean_zs1,std_zs1));
grid on

subplot(2,4,2);
plot(s2'); hold on
plot(mean_s2,'k','LineWidth',3); hold on
title(sprintf('original signal 2'));
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
