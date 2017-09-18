function testsim_z_score_normalization
% test z-score normalization

% variant 1: one task, one condition, two epochs: baseline and response, same noise
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
subplot(2,2,1);
plot(s'); hold on
plot(mean_s,'k','LineWidth',3); hold on
title(sprintf('original signal'));
grid on

% subplot(2,2,2);
% hist([s(idx_b); s(idx_r)]);
% t
% title(sprintf('Z-scored signal: mean %.2f SD %.2f',mean(zs),std(zs)));
% grid on



subplot(2,2,3);
plot(mean(zs,1),'r'); hold on
title(sprintf('Z-scored signal: mean %.2f SD %.2f',mean_zs,std_zs));
grid on

