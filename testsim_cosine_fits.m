function testsim_cosine_fits

for n_bins = [32, 64, 128]

    x = pi/n_bins : 2*pi/n_bins : 2*pi-pi/n_bins;
    
    R = randn(100,n_bins);
    C = cos(x+pi)+1;
    RC = R + C;
    
    [modIndex_RC, removeNoise_RC, allCorr_RC, allLinMod_RC] = fitCardiacModulation(x, RC, {'PSTH'}, 0, [221]);
    
    [modIndex_R, removeNoise_R, allCorr_R, allLinMod_R] = fitCardiacModulation(x, R+1, {'PSTH'}, 0, [221]);
    
    figure
    subplot(2,1,1)
    rc_plot = plot(x, RC, 'b');
    hold on
    c_plot = plot(x, C, 'w', 'LineWidth', 2);
    title('Cosine with Noise')
    legend([rc_plot(1) c_plot], {'Noisy Cosine', 'Original Cosine'})
    
    subplot(2,1,2)
    rm_plot = plot(x, removeNoise_RC, 'k');
    hold on
    c_plot = plot(x, C, 'w', 'LineWidth', 2);
    title({'Smoothed Noisy Cosine', ['Std = ' num2str(std2(removeNoise_RC))]})
    legend([rm_plot(1) c_plot], {'Smoothed Noisy Cosine', 'Original Cosine'})
    
    figure
    [~, h]=bonf_holm(modIndex_RC(:,2));
    sig_MI    = histc(modIndex_RC(h,1), [-5:5]);
    nonsig_MI = histc(modIndex_RC(~h,1), [-5:5]);
    if size(nonsig_MI,1) < size(nonsig_MI,2)
        nonsig_MI = nonsig_MI';
    end
    bar([-5:5], [sig_MI nonsig_MI]', 'stacked')
    title({'Noisy Cosine', 'Scaling Factors from the Linear Fit', ...
        ['std = ' num2str(std(modIndex_RC(:,1)))], ...
        ['True Pos.: ' num2str(sum(sig_MI)) '; False Neg.: ' num2str(sum(nonsig_MI))]})
    legend({'sig', 'nonsig'})
    
    figure
    sig_phase    = histc(modIndex_RC(h,1), [0:0.1:2*pi]);
    nonsig_phase = histc(modIndex_RC(~h,1), [0:0.1:2*pi]);
    if size(nonsig_phase,1) < size(nonsig_phase,2)
        nonsig_phase = nonsig_phase';
    end
    bar([0:0.1:2*pi], [sig_phase nonsig_phase]', 'stacked')
    title({'Noisy Cosine', 'Phases Retrieved by the Linear Fit', ...
        ['std = ' num2str(std(modIndex_RC(:,3)))], ...
        ['True Pos.: ' num2str(sum(sig_MI)) '; False Neg.: ' num2str(sum(nonsig_MI))]})
    legend({'sig', 'nonsig'})
    
    figure,
    [~, h]=bonf_holm(modIndex_R(:,2));
    sig_MI    = histc(modIndex_R(h,1), [-5:5]);
    nonsig_MI = histc(modIndex_R(~h,1), [-5:5]);
    bar([-5:5], [sig_MI nonsig_MI]', 'stacked')
    title({'Gaussian Noise', 'Scaling Factors from the Linear Fit', ...
        ['std = ' num2str(std(modIndex_R(:,1)))], ...
        ['False Pos.: ' num2str(sum(sig_MI)) '; True Neg.: ' num2str(sum(nonsig_MI))]})
    legend({'sig', 'nonsig'})
    
    figure,
    sig_phase    = histc(modIndex_R(h,1), [0:0.1:2*pi]);
    nonsig_phase = histc(modIndex_R(~h,1), [0:0.1:2*pi]);
    bar([0:0.1:2*pi], [sig_phase nonsig_phase]', 'stacked')
    title({'Gaussian Noise', 'Phases Retrieved by the Linear Fit', ['std = ' num2str(std(modIndex_RC(:,3)))]})
    legend({'sig', 'nonsig'})
    
end

end