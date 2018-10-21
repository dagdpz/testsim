function testsim_baseline_control_inactivation

if 1
% variant 1: one task, two conditions (e.g. pre- and post-injection), two epochs: "baseline" and "response"
% the question is, how to assess potential changes in baseline after inactivation, when working with PSC (% signal change)

noise = 10;

% condition 1 (control)
n_trials1 = 50;
n_samples = 200;
baseline_amp1 = 1000;
response_amp1 = 1010;
noise_baseline1 = noise; % the more is noise, the smaller is the z-score
noise_response1 = noise;

% condition 2 (inactivation)
n_trials2 = 25;

baseline_amp2 = 950;
response_amp2 = 955;
noise_baseline2 = noise; % the more is noise, the smaller is the z-score
noise_response2 = noise;


s1 = [baseline_amp1 + noise_baseline1*randn(n_trials1,n_samples/2) response_amp1 + noise_response1*randn(n_trials1,n_samples/2)]; 
idx_b1 = 1:n_samples/2;
idx_r1 = n_samples/2+1:n_samples;
zs1 = zscore(reshape(s1,n_trials1*n_samples,1)); % concatenated trials
zs1 = reshape(zs1,n_trials1,n_samples);
mean_s1 = mean(s1,1);
mean_zs1 = mean(zs1,1);

% psc on original
psc_s1 = (ne_psc(s1',idx_b1))';
mean_psc_s1 = mean(psc_s1,1);

% psc on zscore
psc_zs1 = (ne_psc(zs1',idx_b1))';
mean_psc_zs1 = mean(psc_zs1,1);


s2 = [baseline_amp2 + noise_baseline2*randn(n_trials2,n_samples/2) response_amp2 + noise_response2*randn(n_trials2,n_samples/2)]; 
idx_b2 = 1:n_samples/2;
idx_r2 = n_samples/2+1:n_samples;
zs2 = zscore(reshape(s2,n_trials2*n_samples,1)); % concatenated trials
% condition 2 is zscored using mean and std of condition 1!
% zs2 = (reshape(s2,n_trials2*n_samples,1) - mean(reshape(s1,n_trials1*n_samples,1)))/std(reshape(s1,n_trials1*n_samples,1)); 
zs2 = reshape(zs2,n_trials2,n_samples);
mean_s2 = mean(s2,1);
mean_zs2 = mean(zs2,1);

% psc on original
psc_s2 = (ne_psc(s2',idx_b2))';
mean_psc_s2 = mean(psc_s2,1);

% psc on zscore
psc_zs2 = (ne_psc(zs2',idx_b2))';
mean_psc_zs2 = mean(psc_zs2,1);

% Difference between two conditions
d = mean(s2,1) - mean(s1,1); % raw signal
dz = mean(zs2,1) - mean(zs1,1); % z-scored
dpsc = mean_psc_s2 - mean_psc_s1; % signal change
dpsc_z = mean_psc_zs2 - mean_psc_zs1; % signal change on z-scored

for k = 1:n_samples,
	Cohen_d(k) = computeCohen_d(s2(:,k), s1(:,k)); 
	Cohen_dz(k) = computeCohen_d(zs2(:,k), zs1(:,k)); 
% 	Cohen_dpsc(k) = computeCohen_d(dpsc(:,k), dpsc(:,k)); 
% 	Cohen_dpscz(k) = computeCohen_d(dpscz(:,k), dpscz(:,k)); 
	
	% calculate sample by sample significance on raw data
	[hs(k),ps(k)] = ttest2(s1(:,k),s2(:,k));
	
	% calculate sample by sample significance on z-scored data
	[hz(k),pz(k)] = ttest2(zs1(:,k),zs2(:,k));	
	
	% calculate sample by sample significance PSC
	[hpsc(k),ppsc(k)] = ttest2(psc_s1(:,k),psc_s2(:,k));
	
	% calculate sample by sample significance PSC on z-scored
	[hpsc_z(k),ppsc_z(k)] = ttest2(psc_zs1(:,k),psc_zs2(:,k));	
end

hs_fdr	= fdr_bh(ps);
hz_fdr	= fdr_bh(pz);
hpsc_fdr	= fdr_bh(ppsc);
hpsc_z_fdr	= fdr_bh(ppsc_z);


t = 1:n_samples;

figure('Position',[100 100 1200 900]);
subplot(4,4,1);
plot(s1'); hold on
plot(mean_s1,'k','LineWidth',3); hold on
title(sprintf('original signal 1'));
grid on

subplot(4,4,5);
plot(mean(zs1,1),'k'); hold on
title(sprintf('zs1 %.2f',mean(mean_zs1(idx_r1))));
grid on

subplot(4,4,9);
plot(mean_psc_s1,'k'); hold on
title(sprintf('PSC s1 %.2f',mean(mean_psc_s1(idx_r1))));
grid on

subplot(4,4,13);
plot(mean_psc_zs1,'k'); hold on
title(sprintf('PSC zs1 %.2f',mean(mean_psc_zs1(idx_r1))));
grid on

subplot(4,4,2);
plot(s2'); hold on
plot(mean_s2,'k','LineWidth',3); hold on
title(sprintf('original signal 2'));
grid on

subplot(4,4,6);
plot(mean(zs2,1),'k'); hold on
title(sprintf('zs2 %.2f',mean(mean_zs2(idx_r1))));
grid on

subplot(4,4,10);
plot(mean_psc_s2,'k'); hold on
title(sprintf('PSC s2 %.2f',mean(mean_psc_s2(idx_r2))));
grid on

subplot(4,4,14);
plot(mean_psc_zs2,'k'); hold on
title(sprintf('PSC zs2 %.2f',mean(mean_psc_zs2(idx_r2))));
grid on


% differences

subplot(4,4,3);
plot(t,d,'k','LineWidth',1); hold on
plot(t(hs==1),d(hs==1),'r.');
plot(t(hs_fdr==1),d(hs_fdr==1),'ro');
title(sprintf('s2 - s1'));
grid on

subplot(4,4,7);
plot(t,dz,'k','LineWidth',1); hold on
plot(t(hz==1),dz(hz==1),'r.');
plot(t(hz_fdr==1),dz(hz_fdr==1),'ro');
title(sprintf('zs 2 - zs 1'));
grid on

subplot(4,4,11);
plot(t,dpsc,'k','LineWidth',1); hold on
plot(t(hpsc==1),dpsc(hpsc==1),'r.');
plot(t(hpsc_fdr==1),dpsc(hpsc_fdr==1),'ro');
title(sprintf('psc2 - psc1'));
grid on

subplot(4,4,15);
plot(t,dpsc_z,'k','LineWidth',1); hold on
plot(t(hpsc_z==1),dpsc_z(hpsc_z==1),'r.');
plot(t(hpsc_z_fdr==1),dpsc_z(hpsc_z_fdr==1),'ro');
title(sprintf('psc zs 2 - psc zs 1'));
grid on


subplot(4,4,4);
plot(t,Cohen_d,'k','LineWidth',1); hold on
title(sprintf('Cohen d'));
grid on

subplot(4,4,8);
plot(t,Cohen_dz,'k','LineWidth',1); hold on
title(sprintf('Cohen d on z-scored'));
grid on

elseif 0
% variant 2: one task, two conditions (e.g. pre- and post-injection), two epochs: "baseline" and "response", two trial types (contralesional and ipsilesional)
	close all;
	% 1 - control
	%base1 = 10*ones(1,10); % [0:5:50]; % baseline firing
	base1 = 2:11;
	R1_c = 5:5:50;
	R1_i = 5*ones(1,10);
	% R1_i = ones(size(R1_c))*5;
	
	A1_c = base1 + R1_c;
	A1_i = base1 + R1_i;
	
	% 2 - inactivation
	base2 = base1 + 1;
	R2_c = R1_c;
	R2_i = R1_i;
	
	A2_c = base2 + R2_c;
	A2_i = base2 + R2_i;

	
	TI1 = csi(A1_c,A1_i);
	TI2 = csi(A2_c,A2_i);
	
	TIbc1 = csi(R1_c,R1_i);
	TIbc2 = csi(R2_c,R2_i);
	
	
	map = jet(length(TI1));
	
	subplot(2,2,1)
	for k=1:length(A1_c),	
		plot(A1_c(k),A2_c(k),'o','Color',map(k,:)); hold on
		plot(A1_c(k)-base1(k),A2_c(k)-base2(k),'*','Color',map(k,:)); hold on		
	end
	colorbar
	ig_add_equality_line;
	axis equal
	axis square
	xlabel('control c');
	ylabel('inactivaton c');
	
	subplot(2,2,2)
	for k=1:length(A1_c),	
		plot(A1_i(k),A2_i(k),'o','Color',map(k,:)); hold on
		plot(A1_i(k)-base1(k),A2_i(k)-base2(k),'*','Color',map(k,:)); hold on		
	end
	colorbar
	ig_add_equality_line;
	axis equal
	axis square
	xlabel('control i');
	ylabel('inactivaton c');

	subplot(2,2,3)
	for k=1:length(TI1),	
		plot(TI1(k),TI2(k),'o','Color',map(k,:)); hold on
		plot(TIbc1(k),TIbc2(k),'*','Color',map(k,:)); hold on
	end
	colorbar
	ig_add_equality_line;
	axis equal
	axis square
	xlabel('TI control');
	ylabel('TI inactivaton');
	
	subplot(2,2,4)
	for k=1:length(TI1),	
		plot(1,base2(k)-base1(k),'o','Color',map(k,:)); hold on
		plot(2,A2_c(k)-base2(k)-A1_c(k)+base1(k),'o','Color',map(k,:)); hold on
		plot(4,base2(k)-base1(k),'o','Color',map(k,:)); hold on
		plot(5,A2_i(k)-base2(k)-A1_i(k)+base1(k),'o','Color',map(k,:)); hold on
	end
	colorbar
	set(gca,'Xlim',[0 6]);
	ig_add_zero_lines;


end


function CSI = csi(Contra,Ipsi)

CSI = (Contra-Ipsi)./(Contra+Ipsi);
% CSI = (Contra-Ipsi)./max( [abs(Contra) abs(Ipsi)],[],2 );
% CSI = (Contra-Ipsi);