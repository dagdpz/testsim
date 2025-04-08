% testsim_FR_AMP_correlation

Njunks=10;
nunits=1000;
Nspikes=998;

for u=1:nunits

amps=rand(Nspikes,1);
spikephases=rand(Nspikes,1)*2*pi;


Nbins      = 32;
phase_bin_edges         = linspace(0, 2*pi, Nbins+1);
phase_bins  = pi/Nbins : 2*pi/Nbins : 2*pi-pi/Nbins;


[spikesperbin, ~, bin] = histcounts(spikephases, phase_bin_edges);
% [~,sort_idx]=sort(-amps);
% minspikes=min(spikesperbin);
% amps_s=amps(sort_idx);
% bin_s=bin(sort_idx);
clear AMP_byBin
%if minspikes>=1
    junk=NaN(size(amps));
    junkstart=1;
    junksize=floor(numel(junk)/Njunks);
    for ttemp=1:Njunks
        junk(junkstart:junkstart+junksize-1)=ttemp;
        junkstart=junkstart+junksize;
        AMP_byBin(ttemp,:)= arrayfun(@(x) max([amps(bin == x & junk == ttemp);NaN]), 1:Nbins); % amp by phase
        
    end
    AMP_byBin=nanmean(AMP_byBin);
    % AMP_byBin          = arrayfun(@(x) nanmean(amps_s(find(bin_s == x,ceil(minspikes/10)))), 1:Nbins); % amp by phase
    % AMP_byBin          = arrayfun(@(x) nanmean(amps_s(find(bin_s == x,minspikes))), 1:Nbins); % amp by phase
    % AMP_byBin          = arrayfun(@(x) nanmean(amps_s(find(bin_s == x,1))), 1:Nbins);         % only max by phasebin
    % AMP_byBin          = arrayfun(@(x) nanmean(amps(bin == x)), 1:Nbins);                     % mean by phase
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

