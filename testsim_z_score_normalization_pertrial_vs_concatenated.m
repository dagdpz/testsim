function testsim_z_score_normalization_pertrial_vs_concatenated
% test z-score normalization

% two "conditions", three epochs: "baseline" "response1" "response2"
	
% condition 1
n_trials1 = 25;
n_samples1 = 300;
amp1(1) = 2; % baseline
amp1(2) = 10; % response 1
amp1(3) = 15; % response 2
noise1(1) = 3; % the more is noise, the smaller is the z-score
noise1(2) = 3;
noise1(3) = 3;

% condition 2
n_trials2 = 50;
n_samples2 = n_samples1;
amp2(1) = 2;
amp2(2) = 10;
amp2(3) = 30;
noise2(1) = 3; % the more is noise, the smaller is the z-score
noise2(2) = 3;
noise2(3) = 3;

idx1 = 1:n_trials1;
idx2 = n_trials1+1:n_trials1+n_trials2;

s1 = [amp1(1) + noise1(1)*randn(n_trials1,n_samples1/3) amp1(2) + noise1(2)*randn(n_trials1,n_samples1/3) amp1(3) + noise1(3)*randn(n_trials1,n_samples1/3)]; 
s2 = [amp2(1) + noise2(1)*randn(n_trials2,n_samples2/3) amp2(2) + noise2(2)*randn(n_trials2,n_samples2/3) amp2(3) + noise2(3)*randn(n_trials2,n_samples2/3)]; 
s = [s1; s2]; 

zs = zscore(reshape(s,(n_trials1+n_trials2)*n_samples1,1)); % z-scoring across concatenated trials
zzs = zscore(s,0,2); % z-scoring per trial

zs = reshape(zs,(n_trials1+n_trials2),n_samples1);

mean_s1 = mean(s1,1);
mean_s2 = mean(s2,1);


% Difference between two conditions
d = mean(s2,1) - mean(s1,1); % raw signal
dz = mean(zs(idx2,:),1) - mean(zs(idx1,:),1); % z-scored



t = 1:n_samples1;

figure('Position',[100 100 1200 400]);
subplot(2,3,1);
plot(s1'); hold on
plot(mean_s1,'k','LineWidth',3); hold on
title(sprintf('s1 base resp1 resp2  %s',num2str(amp1)));
grid on

hs4 = subplot(2,3,4);
plot(mean(zs(idx1,:),1),'k'); hold on
plot(mean(zzs(idx1,:),1),'r'); hold on
title(sprintf('Z-scored s1'));
grid on
legend('across trials','per trial');

subplot(2,3,2);
plot(s2'); hold on
plot(mean_s2,'k','LineWidth',3); hold on
title(sprintf('s2 base resp1 resp2  %s',num2str(amp2)));
grid on

hs5 = subplot(2,3,5);
plot(mean(zs(idx2,:),1),'k'); hold on
plot(mean(zzs(idx2,:),1),'r'); hold on
title(sprintf('Z-scored s2'));
grid on

ig_set_axes_equal_lim([hs4 hs5],'all');

subplot(2,3,3);
plot(t,d,'k','LineWidth',1); hold on
title(sprintf('s2 - s1'));
grid on

subplot(2,3,6);
plot(t,dz,'k','LineWidth',1); hold on
title(sprintf('zs 2 - zs 1'));
grid on




end