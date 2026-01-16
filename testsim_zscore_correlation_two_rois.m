function testsim_zscore_correlation_two_rois

% --- Simulate Timecourse Data ---
rng(2024); % Set random seed for reproducibility

numRuns = 3;
samplesPerRun = 300;
totalSamples = numRuns * samplesPerRun;

% Underlying true correlation between ROI1 and ROI2
underlyingCorrelation = 0;
noiseLevel = 0.5;

% Generate correlated data
baseSignal = randn(samplesPerRun, 1); % This base signal is not directly used in the loop as originally intended for simplicity
                                     % Instead, new correlated latent signals are generated per run.

% Initialize data matrices
roi1_raw_all = zeros(totalSamples, 1);
roi2_raw_all = zeros(totalSamples, 1);
roi1_zscored_all = zeros(totalSamples, 1);
roi2_zscored_all = zeros(totalSamples, 1);

% Introduce run-specific mean shifts (confounds)
runMeans_roi1 = [0, 5, -3]; % Mean intensity for ROI1 in each run
runMeans_roi2 = [0, 4, -2]; % Mean intensity for ROI2 in each run

runColors = lines(numRuns); % Colors for plotting each run

figure;
sgtitle('Effect of Z-Scoring on Inter-Run Intensity Differences and Correlation', 'FontSize', 16, 'FontWeight', 'bold');

% --- Process and Plot Data for Each Run ---
subplot(3, 2, 1);
hold on;
title('ROI1: Raw Data by Run');
xlabel('Sample Index (within run)');
ylabel('Intensity');

subplot(3, 2, 2);
hold on;
title('ROI2: Raw Data by Run');
xlabel('Sample Index (within run)');
ylabel('Intensity');

for i = 1:numRuns
    % Generate data for the current run
    % Create some underlying correlated signals for this run
    common_latent_signal = randn(samplesPerRun,1);
    current_roi1_latent = sqrt(underlyingCorrelation) * common_latent_signal + sqrt(1-underlyingCorrelation)*randn(samplesPerRun,1);
    current_roi2_latent = sqrt(underlyingCorrelation) * common_latent_signal + sqrt(1-underlyingCorrelation)*randn(samplesPerRun,1); % Ensure some correlation

    current_roi1_raw = current_roi1_latent + runMeans_roi1(i) + noiseLevel * randn(samplesPerRun, 1);
    current_roi2_raw = current_roi2_latent + runMeans_roi2(i) + noiseLevel * randn(samplesPerRun, 1);

    % Store raw data
    startIndex = (i-1)*samplesPerRun + 1;
    endIndex = i*samplesPerRun;
    roi1_raw_all(startIndex:endIndex) = current_roi1_raw;
    roi2_raw_all(startIndex:endIndex) = current_roi2_raw;

    % Plot raw data for this run
    subplot(3, 2, 1);
    plot(1:samplesPerRun, current_roi1_raw, 'Color', runColors(i,:), 'DisplayName', ['Run ' num2str(i)]);
    subplot(3, 2, 2);
    plot(1:samplesPerRun, current_roi2_raw, 'Color', runColors(i,:), 'DisplayName', ['Run ' num2str(i)]);

    % Z-score this run's data
    current_roi1_zscored = zscore(current_roi1_raw);
    current_roi2_zscored = zscore(current_roi2_raw);

    % Store z-scored data
    roi1_zscored_all(startIndex:endIndex) = current_roi1_zscored;
    roi2_zscored_all(startIndex:endIndex) = current_roi2_zscored;
end
subplot(3,2,1); legend('show','Location','best');
subplot(3,2,2); legend('show','Location','best');
hold off;

% --- Plot Concatenated Data ---
% Raw concatenated
subplot(3, 2, 3);
hold on;
title('ROI1: Concatenated Raw Data');
xlabel('Global Sample Index');
ylabel('Intensity');
for i = 1:numRuns
    startIndex = (i-1)*samplesPerRun + 1;
    endIndex = i*samplesPerRun;
    plot(startIndex:endIndex, roi1_raw_all(startIndex:endIndex), 'Color', runColors(i,:));
end
if numRuns > 1
    boundaries = (1:numRuns-1)*samplesPerRun + 0.5;
    for b_idx = 1:length(boundaries)
        xline(boundaries(b_idx), '--k', 'LineWidth', 1); % Run boundaries
    end
end
hold off;

subplot(3, 2, 4);
hold on;
title('ROI2: Concatenated Raw Data');
xlabel('Global Sample Index');
ylabel('Intensity');
for i = 1:numRuns
    startIndex = (i-1)*samplesPerRun + 1;
    endIndex = i*samplesPerRun;
    plot(startIndex:endIndex, roi2_raw_all(startIndex:endIndex), 'Color', runColors(i,:));
end
if numRuns > 1
    boundaries = (1:numRuns-1)*samplesPerRun + 0.5;
    for b_idx = 1:length(boundaries)
        xline(boundaries(b_idx), '--k', 'LineWidth', 1); % Run boundaries
    end
end
hold off;

% Z-scored concatenated
subplot(3, 2, 5);
hold on;
title('ROI1: Concatenated Z-Scored Data');
xlabel('Global Sample Index');
ylabel('Z-Score');
for i = 1:numRuns
    startIndex = (i-1)*samplesPerRun + 1;
    endIndex = i*samplesPerRun;
    plot(startIndex:endIndex, roi1_zscored_all(startIndex:endIndex), 'Color', runColors(i,:));
end
if numRuns > 1
    boundaries = (1:numRuns-1)*samplesPerRun + 0.5;
    for b_idx = 1:length(boundaries)
        xline(boundaries(b_idx), '--k', 'LineWidth', 1); % Run boundaries
    end
end
yline(0, ':k'); % Mean line
hold off;

subplot(3, 2, 6);
hold on;
title('ROI2: Concatenated Z-Scored Data');
xlabel('Global Sample Index');
ylabel('Z-Score');
for i = 1:numRuns
    startIndex = (i-1)*samplesPerRun + 1;
    endIndex = i*samplesPerRun;
    plot(startIndex:endIndex, roi2_zscored_all(startIndex:endIndex), 'Color', runColors(i,:));
end
if numRuns > 1
    boundaries = (1:numRuns-1)*samplesPerRun + 0.5;
    for b_idx = 1:length(boundaries)
        xline(boundaries(b_idx), '--k', 'LineWidth', 1); % Run boundaries
    end
end
yline(0, ':k'); % Mean line
hold off;

% --- Calculate Correlations ---
% Correlation on raw concatenated data
corr_raw = corrcoef(roi1_raw_all, roi2_raw_all);
corr_raw_value = corr_raw(1,2);

% Correlation on z-scored (per run) concatenated data
corr_zscored = corrcoef(roi1_zscored_all, roi2_zscored_all);
corr_zscored_value = corr_zscored(1,2);

% --- Display Correlation Results ---
disp('--- Correlation Results ---');
fprintf('Correlation on raw concatenated data: R = %.4f\n', corr_raw_value);
fprintf('Correlation on z-scored (per run) concatenated data: R = %.4f\n', corr_zscored_value);
fprintf('Simulated underlying correlation for latent signals was: %.2f\n', underlyingCorrelation);

% Add correlation values to the plot title
% Ensure sgtitle is applied to the correct figure if multiple figures exist.
% For a single figure script like this, gcf should be fine.
figHandle = gcf;
try
    current_super_title_obj = findall(figHandle, 'Type', 'suptitle');
    if ~isempty(current_super_title_obj)
        current_sgtitle_text = current_super_title_obj.String;
        if iscell(current_sgtitle_text) % If String is a cell array
            current_sgtitle_text = current_sgtitle_text{1};
        end
    else % Fallback if suptitle object not found or not standard
        current_sgtitle_text = 'Effect of Z-Scoring'; % Default or extract differently
    end
catch
    current_sgtitle_text = 'Effect of Z-Scoring'; % Fallback
end

new_sgtitle = sprintf('%s\nRaw Concatenated Corr: R = %.3f\nZ-Scored (per run) Concatenated Corr: R = %.3f (Target ~%.2f)', ...
    current_sgtitle_text, corr_raw_value, corr_zscored_value, underlyingCorrelation);
sgtitle(new_sgtitle);


% Adjust layout
set(gcf, 'Position', [100, 100, 1000, 900]); % Make figure larger to accommodate new title