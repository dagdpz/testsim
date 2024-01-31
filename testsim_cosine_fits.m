function testsim_cosine_fits

bin_list = [32, 64, 128, 256];

for n_bins = 1:length(bin_list)

    x = pi/bin_list(n_bins) : 2*pi/bin_list(n_bins) : 2*pi-pi/bin_list(n_bins);
    
    R = randn(100,bin_list(n_bins));
    C = cos(x+pi)+1;
    RC = R + C;
    
    [modIndex_RC, removeNoise_RC, allCorr_RC, allLinMod_RC] = fitCardiacModulation(x, RC, {'PSTH'}, 0, [221]);
    
    [modIndex_R, removeNoise_R, allCorr_R, allLinMod_R] = fitCardiacModulation(x, R+1, {'PSTH'}, 0, [221]);
    
    
    % plot the original data
    figure(1)
    set(1, 'Position', [591 117 1153 420])
    subplot(1,length(bin_list),n_bins)
    rc_plot = plot(x, RC, 'k');
    hold on
    sm_plot = plot(x, removeNoise_RC, 'Color', [255 120 0]/255);
    c_plot  = plot(x, C, 'y', 'LineWidth', 2);
    title({['Cosine with Noise: N bins ' num2str(bin_list(n_bins))]})
    if n_bins == 1
        legend([rc_plot(1) sm_plot(1) c_plot], {'Noisy Cosine', 'Smoothed Noisy Cosine', 'Original Cosine'}, 'Location', 'Best')
    end
    xlim([0 2*pi])
    ylim([-5 5])
    
    figure(2)
    set(2, 'Position', [591 117 1153 420])
    subplot(1,length(bin_list),n_bins)
    h = modIndex_RC(:,2) < 0.05;
%     [~, h]=bonf_holm(modIndex_RC(:,2));
%     [h, crit_p]=fdr_bky(modIndex_RC(:,2));
    sig_MI    = histc(modIndex_RC(h,1), [-1:0.5:5]);
    nonsig_MI = histc(modIndex_RC(~h,1), [-1:0.5:5]);
    if size(nonsig_MI,1) < size(nonsig_MI,2)
        nonsig_MI = nonsig_MI';
    end
    bar([-1:0.5:5], [sig_MI nonsig_MI]', 'stacked')
    title({'Noisy Cosine', 'Scaling Factors from the Linear Fit', ...
        ['std = ' num2str(std(modIndex_RC(:,1)))], ...
        ['True Pos.: ' num2str(sum(sig_MI)) '; False Neg.: ' num2str(sum(nonsig_MI))]})
    legend({'sig', 'nonsig'})
    
    figure(3)
    set(3, 'Position', [591 117 1153 420])
    subplot(1,length(bin_list),n_bins)
    sig_phase    = histc(modIndex_RC(h,3), [0:0.1:2*pi]);
    nonsig_phase = histc(modIndex_RC(~h,3), [0:0.1:2*pi]);
    if size(nonsig_phase,1) < size(nonsig_phase,2)
        nonsig_phase = nonsig_phase';
    end
    bar([0:0.1:2*pi], [sig_phase nonsig_phase]', 'stacked')
    title({'Noisy Cosine', 'Phases Retrieved by the Linear Fit', ...
        ['std = ' num2str(std(modIndex_RC(:,3)))], ...
        ['True Pos.: ' num2str(sum(sig_MI)) '; False Neg.: ' num2str(sum(nonsig_MI))]})
    legend({'sig', 'nonsig'})
    
    figure(4)
    set(4, 'Position', [591 117 1153 420])
    subplot(1,length(bin_list),n_bins)
    h = modIndex_R(:,2) < 0.05;
%     [~, h]=bonf_holm(modIndex_R(:,2));
%     [h, ~]=fdr_bky(modIndex_RC(:,2));
    sig_MI    = histc(modIndex_R(h,1), [-1:0.5:5]);
    nonsig_MI = histc(modIndex_R(~h,1), [-1:0.5:5]);
    bar([-1:0.5:5], [sig_MI nonsig_MI]', 'stacked')
    title({'Gaussian Noise', 'Scaling Factors from the Linear Fit', ...
        ['std = ' num2str(std(modIndex_R(:,1)))], ...
        ['False Pos.: ' num2str(sum(sig_MI)) '; True Neg.: ' num2str(sum(nonsig_MI))]})
    legend({'sig', 'nonsig'})
    
    figure(5)
    set(5, 'Position', [591 117 1153 420])
    subplot(1,length(bin_list),n_bins)
    sig_phase    = histc(modIndex_R(h,3), [0:0.1:2*pi]);
    nonsig_phase = histc(modIndex_R(~h,3), [0:0.1:2*pi]);
    bar([0:0.1:2*pi], [sig_phase nonsig_phase]', 'stacked')
    title({'Gaussian Noise', 'Phases Retrieved by the Linear Fit', ['std = ' num2str(std(modIndex_R(:,3)))]})
    legend({'sig', 'nonsig'})
    
end

end

function out = circ_smooth2(input)

if size(input, 1) < size(input, 2)
    input = input';
end

A = repmat(input, 3, 1);
A_smoothed = smooth(A, 'rlowess');

out = A_smoothed(length(input)+1:end-length(input));

end