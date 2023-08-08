function testsim_spike_waveform_snr


tic
nSamples = 40;

Fs = nSamples*1000; % Hz

% Design a low-pass filter to introduce correlation in the noise
cutoff_frequency = 5000;  % cutoff frequency in Hz
[b, a] = butter(2, cutoff_frequency/(Fs/2), 'low');


t = [0:1:nSamples-1]/(1000*nSamples); % nSamples in 1 ms
s = cos(2*pi*t*1500);
s(t<0.0002) = 0;
s(t>0.0008) = 0;
s(s<0) = s(s<0)*2;

PLOT_WF = 1;
subset_percent = 5; % percent of spikes to plot

levelsNoise = 0.1:0.3:1;
numSpikes = round(logspace(log10(100), log10(100000), 5));
n_levelsNoise = length(levelsNoise);
n_numSpikes = length(numSpikes);

figure(1);

set(gcf, 'GraphicsSmoothing', 'on');  % Turn off graphics smoothing
set(gca, 'SortMethod', 'depth');  % Change sort method

n_subplot = 0;
SNR = zeros(n_levelsNoise,n_numSpikes);
for ln = 1:n_levelsNoise
    for ns = 1:n_numSpikes
        
        noise = filter(b, a, levelsNoise(ln)*randn(numSpikes(ns),nSamples),[],2) + levelsNoise(ln)*randn(numSpikes(ns),1);
        
        wf = s + noise;
        [SNR(ln,ns), meanWF, subsetWF] = calcSNR(wf,subset_percent);
        
        if PLOT_WF
            n_subplot = n_subplot + 1;
            subplot(n_levelsNoise,n_numSpikes,n_subplot);
            plot(t,subsetWF); hold on
            % line(t,subsetWF); hold on;
            plot(t,meanWF,'k','LineWidth',2);
            title(sprintf('%d spikes',size(subsetWF,1)));
        end
    end
end

if PLOT_WF
    ig_set_axes_equal_lim(get(gcf,'Children'),'Ylim');
end

figure(2);

imagesc(SNR);
set(gca,'Xtick',1:length(numSpikes),'XtickLabels',numSpikes);
xlabel('Number of spikes');
set(gca,'Ytick',1:length(levelsNoise),'YtickLabels',levelsNoise);
ylabel('Levels of noise');

colorbar

toc



function [SNR, meanWF, subsetWF] = calcSNR(wf,subset_percent)

meanWF = mean(wf,1);
A = max(meanWF) - min(meanWF);
SNR = A / mean(std(wf,1));

% Compute number of rows to select
num_rows_to_select = ceil(size(wf, 1) * (subset_percent / 100));

% Randomly select rows
subsetWF = wf(randsample(size(wf, 1), num_rows_to_select),:);


