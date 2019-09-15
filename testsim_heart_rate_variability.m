function testsim_heart_rate_variability

N_rep = 100; % number of repetitions for each condition

segment_duration = [300 600]; % s
meanBPM = [60:120]; % bpm, HR
sdBPM = [20]; % bpm, HRV -- what does this actually mean? relative to HR!

i_n = length(meanBPM);
j_n = length(sdBPM);
s_n = length(segment_duration);
HR = zeros(i_n,j_n,s_n,N_rep);
RRSD = HR;
RMSSD = HR;
colormap = jet(j_n);

for i = 1:i_n
    for j = 1:j_n
        for s = 1:s_n                
            % calculate approximate number of cycles to fit into segment_duration with this meanP2P
            n_cycles = fix(segment_duration(s)*meanBPM(i)/60); 
            
            for k = 1:N_rep,
                % bpm = meanBPM(i) + sdBPM(j)*randn(1,n_cycles); % distribution of BPMs
                % p2p = 60./bpm; % peak2peak in s
                p2p = 60/meanBPM(i) + 60/meanBPM(i)*(sdBPM(j)/meanBPM(i))*randn(1,n_cycles);% dostribution of p2p in s
                p2p_ = p2p;
%                 P = prctile(p2p_,[30 70]); p2p = p2p_(p2p_>P(1) & p2p_<P(2));
                % p2p = p2p(p2p>0);
                
                if 0 % debug
                    % [h1,bins] = hist(60./bpm); bar(bins,h1); hold on;
                    [h1,bins] = hist(p2p_); bar(bins,h1); hold on;
                    [h2] = hist(p2p,bins); bar(bins,h2,'r');
                    pause;
                    cla;
                end
                
                HR(i,j,s,k) = mean(60./p2p);
                RRSD(i,j,s,k) = std(60./p2p);
                RMSSD(i,j,s,k)= sqrt(mean(diff(60./p2p).^2));
            end
        end
    end
end


figure('Position',[300 300 1100 900]);

for s = 1:s_n,
   
   hr_mean = squeeze(mean(HR(:,:,s,:),4));
   hr_std = squeeze(std(HR(:,:,s,:),0,4));
   
   rrsd_mean = squeeze(mean(RRSD(:,:,s,:),4));
   rrsd_std = squeeze(std(RRSD(:,:,s,:),0,4));
   
   rmssd_mean = squeeze(mean(RMSSD(:,:,s,:),4));
   rmssd_std = squeeze(std(RMSSD(:,:,s,:),0,4));
   
   subplot(length(segment_duration),2,2*s-1);
   for j = 1:j_n,
        plot(hr_mean(:,j),rrsd_mean(:,j),'.','Color',colormap(j,:)); hold on
   end
   xlabel('HR')
   ylabel('RRSD')
   title(['segment ' num2str(segment_duration(s)) ' s']);
   
   subplot(length(segment_duration),2,2*s);
   for j = 1:j_n,
        plot(hr_mean(:,j),rmssd_mean(:,j),'.','Color',colormap(j,:)); hold on
   end
   xlabel('HR')
   ylabel('RMSSD')
   title(['segment ' num2str(segment_duration(s)) ' s']);
   
end






	
