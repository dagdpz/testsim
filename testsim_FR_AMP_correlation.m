function testsim_FR_AMP_correlation

Njunks=10;
nunits=1000;
Nspikes=10000;

cutoffamp=0.5;
modified_phase=pi;
affected_phase_range=pi/10;


cardioballistic_shift=0.3; % if groundtruth is cardioballistic, shift amplitude cutoff by this amount
fr_reduction=0.2;           % if groundtruth is firing rate decrease, remove this fraction from respective bins


method = 'fittruncated';
groundtruth = 'cardioballistic' ; %'firing rate decrease'
for u=1:nunits
    ratio_discarded=normcdf(cutoffamp, 0, 1);
    Nspikes=Nspikes/(1-ratio_discarded);
    amps=randn(round(Nspikes),1);
    amps(amps<cutoffamp)=[];
    spikephases=rand(numel(amps),1)*2*pi;
    
    switch groundtruth
        case 'cardioballistic'
            idx1=(modified_phase-affected_phase_range)<spikephases & spikephases<(modified_phase+affected_phase_range); % from desired bins
            amps(idx1)=amps(idx1)-cardioballistic_shift;
            
            idx_remove=amps<cutoffamp;
            
        case 'firing rate decrease'
            idx1=(modified_phase-affected_phase_range)<spikephases & spikephases<(modified_phase+affected_phase_range); % from desired bins
            idx2=rand(1,numel(amps))<fr_reduction;                                                        % desired fraction
            
            idx_remove=idx1 & idx2;
    end
    amps(idx_remove)=[];
    spikephases(idx_remove)=[];
    
    Nbins      = 32;
    phase_bin_edges         = linspace(0, 2*pi, Nbins+1);
    phase_bin_edges2         = linspace(0, 2*pi, Nbins);
    phase_bins  = pi/Nbins : 2*pi/Nbins : 2*pi-pi/Nbins;
    
    
    %[spikesperbin, ~, bin] = histcounts(spikephases, phase_bin_edges);
    [spikesperbin, bin] = histc(spikephases, phase_bin_edges2);
    
    %% resort for methods 'meanoflargestminNspikes' and 'onlylargest'
    [~,sort_idx]=sort(-amps);
    minspikes=min(spikesperbin);
    amps_s=amps(sort_idx);
    bin_s=bin(sort_idx);
    clear AMP_byBin
    %if minspikes>=1
    
    switch method
        case 'maxofjunks'
            junk=NaN(size(amps));
            junkstart=1;
            junksize=floor(numel(junk)/Njunks);
            for ttemp=1:Njunks
                junk(junkstart:junkstart+junksize-1)=ttemp;
                junkstart=junkstart+junksize;
                AMP_byBin(ttemp,:)= arrayfun(@(x) max([amps(bin == x & junk == ttemp);NaN]), 1:Nbins); % amp by phase
            end
            AMP_byBin=nanmean(AMP_byBin);
        case 'meanoflargestminNspikes'
            AMP_byBin          = arrayfun(@(x) nanmean(amps_s(find(bin_s == x,minspikes))), 1:Nbins); % amp by phase
        case 'onlylargest'
            AMP_byBin          = arrayfun(@(x) nanmean(amps_s(find(bin_s == x,1))), 1:Nbins);         % only max by phasebin
        case 'mean'
            AMP_byBin          = arrayfun(@(x) nanmean(amps(bin == x)), 1:Nbins);                     % mean by phase
        case 'fittruncated'
            for b=1:Nbins
                if any(bin == b)
            [norm_trunc, phat, phat_ci]  = fitdist_ntrunc_l(amps(bin == b), cutoffamp);
            AMP_byBin(b)=phat(1);
                else
                  AMP_byBin(b)=NaN;  
                end
            end
            
    end
    FR_byBin             = arrayfun(@(x) sum(bin == x), 1:Nbins); % FR by phase
    % else
    %     AMP_byBin            = arrayfun(@(x) nanmean(amps(bin == x)), 1:Nbins); % mean by phase
    %     FR_byBin             = zeros(size(AMP_byBin)); % FR by phase
    % end
    
    [cct, pvalt]             = corrcoef(FR_byBin, AMP_byBin);
    
    cc(u)   = cct(2,1);
    pval(u)    = pvalt(2,1);
    MI(u)   =max(FR_byBin)-min(FR_byBin);
end

figure
scatter(cc,MI)
%
% x1=1;
% x2=1.1;
% X=-5:0.05:5;
% gaussian=normpdf(X);
% figure
% plot(X,gaussian)
% A=sum(gaussian(X>=x1).*X(X>=x1))/sum(gaussian(X>=x1));
% B=sum(gaussian(X>=x2).*(X(X>=x2)-x2+x1))/sum(gaussian(X>=x2));
% export_fig('C:\Users\lschneider\Desktop\gaussian','-pdf')
end

function [norm_trunc, phat, phat_ci]  = fitdist_ntrunc_l(dat_normal, x_min)
% Alexey Ryabov.
%2018/02/08  added the posibility to fit data truncted on the left, right and
%both sides
%2017/08/08
% Fitting the truncated Gaussian distribution
% [norm_trunc, phat, phat_ci]  = fitdist_ntrunc(dat_normal, Range)
% norm_trunc -- truncated Gaussian distribution
% phat -- the maximal likelyhood estimates for \mu and \sigma for this distribution
% phat_ci -- confidence intervals for \mu and \sigma
% dat_normal -- normally distributed data
% Range - if not defined then the min and max in dat_normal will be used
% Range verctor with two elements defining the range where the data is truncated
% for instance
% [norm_trunc, phat, phat_ci]  = fitdist_ntrunc(dat_normal, [2, 10])  %-- the data is truncated on both sides
% [norm_trunc, phat, phat_ci]  = fitdist_ntrunc(dat_normal, [2, Inf]) %-- the data is truncated on the left
% [norm_trunc, phat, phat_ci]  = fitdist_ntrunc(dat_normal, [-Inf, 10]) %-- the data is truncated on the right
% [norm_trunc, phat, phat_ci]  = fitdist_ntrunc(dat_normal, [-Inf, 10]) %-- the data is truncated on the right
% [norm_trunc, phat, phat_ci]  = fitdist_ntrunc(dat_normal, [NaN, 10]) %--
% the data is truncated on both sides,but the left border will be defined
% automatically as min(dat_normal)
% Example
% mu1 = 3; sigma1 = 5;
% pd = makedist('Normal', 'mu', mu1,'sigma', sigma1);
% dat_normal = pd.random(10000, 1);
% %remove all values less than 1
% dat_normal = dat_normal(dat_normal>x_min);
% %fit the distribution
% [norm_trunc, phat, phat_ci] = fitdist_ntrunc(dat_normal);
% %Plot results
% figure(1)
% plot(x, (norm_trunc(x , phat(1), phat(2))))

%The truncated pdf should be normilized. If we truncate from the left, then
%we divide by normcdf(-x_min, -mu, sigma)
heaviside_l = @(x) 1.0*(x>=0); %define double Heaviside function, because in Matlab 2017 Heaviside returns sym instead of double
norm_trunc =@(x, mu, sigma) (normpdf(x , mu, sigma)./normcdf(-x_min, -mu, sigma) .* heaviside_l(x - x_min));
%find the maximum likelihood estimates using mean and std as an initial guess
try
[phat, phat_ci]  = mle(dat_normal , 'pdf', norm_trunc,'start', [mean(dat_normal), std(dat_normal)]);
catch eee
   whatswrongnow=1; 
end
end

