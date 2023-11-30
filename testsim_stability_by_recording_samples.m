function testsim_stability_by_recording_samples


noise_std=10;
start_FR=50;
drifts=0:0.1:0.4;
N_samples=300;
n_repetions=100;
minsamples=10;

figure
Ndrfits=numel(drifts);
for d=1:Ndrfits
    drift=drifts(d);
    subplot(ceil(sqrt(Ndrfits)),ceil(sqrt(Ndrfits)),d);
    
    clear fano_factor fanoish_factor FRs
    for N=1:N_samples
        clear FRs
        for R=1:n_repetions
            FRs(:,R)=(1:N)*drift+randn(size(1:N))*noise_std+start_FR;
        end
        
        
        fano_factor=1./(var(FRs)./mean(FRs));
        fanoish_factor=1./(std(FRs)./mean(FRs));
        percentile_factor=1./(diff(prctile(FRs,[33,66]))./mean(FRs));
        
        
        fano_factor_max(N)=noise_std*max(fano_factor);
        fanoish_factor_max(N)=max(fanoish_factor);
        percentile_factor_max(N)=max(percentile_factor);        
        
        fano_factor_min(N)=noise_std*min(fano_factor);
        fanoish_factor_min(N)=min(fanoish_factor);
        percentile_factor_min(N)=min(percentile_factor);
        
        
        fano_factor_med(N)=noise_std*median(fano_factor);
        fanoish_factor_med(N)=median(fanoish_factor);
        percentile_factor_med(N)=median(percentile_factor);
        
    end
    lineProps={'linestyle','-'};
    hold on
    
    m=minsamples;
    FFM  = fano_factor_max(m:end);
    FFm  = fano_factor_min(m:end);
    FF   = fano_factor_med(m:end);
    
    FIM  = fanoish_factor_max(m:end);
    FIm  = fanoish_factor_min(m:end);
    FI   = fanoish_factor_med(m:end);
    
    PFM  = percentile_factor_max(m:end);
    PFm  = percentile_factor_min(m:end);
    PF   = percentile_factor_med(m:end);


    
    shadedErrorBar(m:N_samples,FF,[FFM-FF;FF-FFm],lineProps,1);
    shadedErrorBar(m:N_samples,FI,[FIM-FI;FI-FIm],lineProps,1);
    shadedErrorBar(m:N_samples,PF,[PFM-PF;PF-PFm],lineProps,1);
    
    
    
    legend({'noisestd/fano factor','1/fanoish factor','1/percentile factor'});
    xlabel('N samples')
    title(['drift: ' num2str(drift)]);
end

end