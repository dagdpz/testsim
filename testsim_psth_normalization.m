% function testsim_psth_normalization
% different normalization approaches for PSTH

N = 30; % number of neurons
n_trials = 40;
n_samples = 100; 

% set this:
normalization = 'divisive across cond';
situation = 'contra space, contra hand already in fix';

% 4 conditions
switch situation
   
    case 'contra space, contra hand already in fix'
  
        % 1 CHCS
        b(1) = 0.5;
        r(1) = 1;

        % 2 CHIS
        b(2) = 0.5;
        r(2) = 0.8;

        % 3 IHCS
        b(3) = 0.2;
        r(3) = 0.7;

        % 4 IHIS
        b(4) = 0.2;
        r(4) = 0.5;
        
end

idx_b = 1:n_samples/2;
idx_r = n_samples/2+1:n_samples;

R = zeros(N,4,n_trials,n_samples);

low_fr = 1; high_fr  = 30; RA = low_fr + (high_fr-low_fr).*rand(N,1); % average response amplitude level for each neuron, between low and high
noise = 0.01 + (0.5-0.01).*rand(N,1);

for c = 1:4,
    
    for n = 1:N, % for each neuron
        R(n,c,:,idx_b)=b(c)*RA(n)*(ones(n_trials,length(idx_b))+noise(n)*randn(n_trials,length(idx_b)));
        R(n,c,:,idx_r)=r(c)*RA(n)*(ones(n_trials,length(idx_b))+noise(n)*randn(n_trials,length(idx_b)));
        
    end  
    
end


figure('Position',[100 100 1200 400]);
subplot(2,4,1);
plot(squeeze(mean(R(:,1,:,:),3))'); hold on
plot(mean(squeeze(mean(R(:,1,:,:),3)),1),'k','LineWidth',3);
title(['CHCS']);

subplot(2,4,2);
plot(squeeze(mean(R(:,2,:,:),3))'); hold on
plot(mean(squeeze(mean(R(:,2,:,:),3)),1),'k','LineWidth',3);
title('CHIS');

subplot(2,4,3);
plot(squeeze(mean(R(:,3,:,:),3))'); hold on
plot(mean(squeeze(mean(R(:,3,:,:),3)),1),'k','LineWidth',3);
title('IHCS');

subplot(2,4,4);
plot(squeeze(mean(R(:,4,:,:),3))'); hold on
plot(mean(squeeze(mean(R(:,4,:,:),3)),1),'k','LineWidth',3);
title('IHIS');

ig_set_axes_equal_lim(get(gcf,'Children'),'all')



switch normalization
    
    case 'divisive across cond'
        
        nor = squeeze(mean(R(:,:,:,idx_b),4));
        nor = reshape(nor,N,4*n_trials);
        nor = mean(nor,2);
        
        for n=1:N,
            Rn(n,:,:,:) = R(n,:,:,:)/nor(n);
        end
    
end

hn(1) = subplot(2,4,5);
plot(squeeze(mean(Rn(:,1,:,:),3))'); hold on
plot(mean(squeeze(mean(Rn(:,1,:,:),3)),1),'k','LineWidth',3);
title([situation ', normalization: ' normalization]);

hn(2) = subplot(2,4,6);
plot(squeeze(mean(Rn(:,2,:,:),3))'); hold on
plot(mean(squeeze(mean(Rn(:,2,:,:),3)),1),'k','LineWidth',3);
hn(3) = subplot(2,4,7);
plot(squeeze(mean(Rn(:,3,:,:),3))'); hold on
plot(mean(squeeze(mean(Rn(:,3,:,:),3)),1),'k','LineWidth',3);
hn(4) = subplot(2,4,8);
plot(squeeze(mean(Rn(:,4,:,:),3))'); hold on
plot(mean(squeeze(mean(Rn(:,4,:,:),3)),1),'k','LineWidth',3);

ig_set_axes_equal_lim(hn,'all');






