% testsim_cluster_perm_surrogate_trigger
% Cluster-based permutation test for trigger-locked (e.g., R-peak) modulation
% Tests if observed effects are significantly time-locked to trigger vs. random alignment
%
% Approach:
%   - Actual data: trials aligned to trigger (R-peak at 500ms)
%   - Surrogate: each trial circularly shifted by random amount (0-1000ms)
%   - Null hypothesis: effects are NOT time-locked to trigger
%
% Based on testsim_cluster_perm_two_conditions_1D_vector_valued_stats.m

clear; close all; rng(42);

%% ========================================================================
%  PART 1: PARAMETERS
%  ========================================================================

fprintf('Setting up surrogate trigger test...\n');

% Trial structure
n_trials = 200;            % Number of trials
n_timepoints = 1000;       % Time points per trial (1000ms at 1000Hz)
sampling_rate = 1000;      % Hz
time = (0:n_timepoints-1) / sampling_rate;  % Time in seconds
trigger_time_ms = 500;     % R-peak location (ms)

% Permutation parameters
n_permutations = 1000;

% MINIMUM CLUSTER SIZE
min_cluster_size = 10;     % Minimum samples to be considered a cluster

% CLUSTER-FORMING THRESHOLD
cluster_p_thresh = 0.05;   % Two-sided p-value for initial thresholding

% T-VALUE SMOOTHING
smooth_t_ms = 20;          % Gaussian smoothing of t-values (ms), 0 to disable
smooth_t_samples = round(smooth_t_ms * sampling_rate / 1000);

% Family-wise error rate
alpha = 0.05;

% INFERENCE METHOD
use_vector_valued = true;  % true: dimension-specific nulls (Section 4.5)
                           % false: max-stat only

fprintf('  Trials: %d\n', n_trials);
fprintf('  Trigger at: %d ms\n', trigger_time_ms);
fprintf('  Minimum cluster size: %d samples (%.1f ms)\n', min_cluster_size, min_cluster_size);
fprintf('  Cluster-forming threshold: p < %.3f\n', cluster_p_thresh);
if use_vector_valued
    fprintf('  Inference: Vector-valued (Section 4.5)\n');
else
    fprintf('  Inference: Standard (max-stat only)\n');
end

%% ========================================================================
%  PART 2: SIMULATE DATA
%  ========================================================================

fprintf('\nGenerating trial data...\n');

% Noise parameters
noise_std = 2.5;
noise_smooth_ms = 10;  % Temporal smoothing for correlated noise
noise_smooth_samples = round(noise_smooth_ms * sampling_rate / 1000);

% Generate baseline noise
trials = noise_std * randn(n_trials, n_timepoints);

% Apply temporal smoothing to create correlated noise
if noise_smooth_samples > 0
    fprintf('  Applying %.0f ms Gaussian smoothing to noise...\n', noise_smooth_ms);
    for trial = 1:n_trials
        trials(trial, :) = smoothdata(trials(trial, :), 'gaussian', noise_smooth_samples);
    end
    % Re-scale to maintain original std
    trials = trials * (noise_std / std(trials(:)));
end

% Add TRUE EFFECTS (time-locked to trigger at 500ms)
% CLUSTER 1: 600-700 ms (100-200 ms post-trigger)
cluster1_time = 600:700;
cluster1_amplitude = 0.7;
trials(:, cluster1_time) = trials(:, cluster1_time) + cluster1_amplitude;

% CLUSTER 2: 750-800 ms (250-300 ms post-trigger)
cluster2_time = 750:800;
cluster2_amplitude = 0.5;
trials(:, cluster2_time) = trials(:, cluster2_time) + cluster2_amplitude;

fprintf('  True effect clusters (relative to trigger at %d ms):\n', trigger_time_ms);
fprintf('    Cluster 1: %d-%d ms (%d samples, amplitude: %.2f)\n', ...
    cluster1_time(1), cluster1_time(end), length(cluster1_time), cluster1_amplitude);
fprintf('    Cluster 2: %d-%d ms (%d samples, amplitude: %.2f)\n', ...
    cluster2_time(1), cluster2_time(end), length(cluster2_time), cluster2_amplitude);

%% ========================================================================
%  PART 3: CALCULATE OBSERVED STATISTICS
%  ========================================================================

fprintf('\nCalculating observed statistics...\n');

% One-sample t-test: is mean significantly different from 0?
[observed_clusters, observed_tvals, n_clusters_before_filter] = ...
    calculate_cluster_stats_one_sample(trials, min_cluster_size, smooth_t_samples, cluster_p_thresh);

fprintf('  Detected %d clusters before size filter\n', n_clusters_before_filter);
fprintf('  Retained %d clusters after size filter (>= %d samples)\n', ...
    length(observed_clusters), min_cluster_size);

if isempty(observed_clusters)
    error('No clusters found! Try lowering min_cluster_size or increasing effect sizes.');
end

% Sort by absolute cluster mass
[observed_vector, sort_idx] = sort(abs([observed_clusters.mass]), 'descend');
observed_clusters_sorted = observed_clusters(sort_idx);

fprintf('  Observed cluster masses (sorted): ');
fprintf('%.1f ', observed_vector);
fprintf('\n');

%% ========================================================================
%  PART 4: BUILD PERMUTATION (SURROGATE) DISTRIBUTION
%  ========================================================================

fprintf('\nRunning %d surrogate permutations...\n', n_permutations);

% PRE-GENERATE ALL RANDOM SHIFTS
fprintf('  Generating random shift indices...\n');
random_shifts = randi([0, n_timepoints-1], n_permutations, n_trials);

% Pre-compute constants
df = n_trials - 1;
t_thresh = tinv(1 - cluster_p_thresh/2, df);
row_idx = repmat((1:n_trials)', 1, n_timepoints);  % [n_trials × n_timepoints]
col_base = 1:n_timepoints;  % [1 × n_timepoints]

% Storage
perm_vectors = cell(n_permutations, 1);
debug_clusters_before = zeros(n_permutations, 1);
debug_clusters_after = zeros(n_permutations, 1);

% SINGLE LOOP: shift → t-test → cluster finding
fprintf('  Computing surrogates (shift + t-test + clusters)...\n');
for perm = 1:n_permutations
    % 1. Circular shift all trials (vectorized indexing)
    shifts = random_shifts(perm, :)';
    shifted_col_idx = mod(bsxfun(@minus, col_base, shifts) - 1, n_timepoints) + 1;
    linear_idx = sub2ind(size(trials), row_idx, shifted_col_idx);
    shifted_trials = trials(linear_idx);
    
    % 2. One-sample t-test (vectorized across timepoints)
    trial_mean = mean(shifted_trials, 1);
    trial_std = std(shifted_trials, 0, 1);
    tvals = trial_mean ./ (trial_std / sqrt(n_trials));
    
    % 3. Smooth if requested
    if smooth_t_samples > 0
        tvals_for_thresh = smoothdata(tvals, 'gaussian', smooth_t_samples);
    else
        tvals_for_thresh = tvals;
    end
    
    % 4. Find clusters (bwconncomp)
    [clusters, n_before] = find_clusters_from_tvals(tvals, tvals_for_thresh, t_thresh, min_cluster_size);
    
    debug_clusters_before(perm) = n_before;
    debug_clusters_after(perm) = length(clusters);
    
    if ~isempty(clusters)
        perm_vectors{perm} = sort(abs([clusters.mass]), 'descend');
    else
        perm_vectors{perm} = [];
    end
end

% DEBUG output
fprintf('\n  DEBUG: Surrogate cluster stats:\n');
fprintf('    Clusters before size filter: mean=%.1f, max=%d\n', ...
    mean(debug_clusters_before), max(debug_clusters_before));
fprintf('    Clusters after size filter: mean=%.1f, max=%d\n', ...
    mean(debug_clusters_after), max(debug_clusters_after));
fprintf('    Surrogates with >=1 cluster: %d\n', sum(debug_clusters_after >= 1));

%% ========================================================================
%  PART 5: BUILD DIMENSION-SPECIFIC DISTRIBUTIONS
%  ========================================================================

fprintf('\nBuilding dimension-specific distributions...\n');

max_dimensions = length(observed_vector);
fprintf('  Number of observed clusters (dimensions): %d\n', max_dimensions);

dimension_distributions = cell(max_dimensions, 1);

for dim = 1:max_dimensions
    dim_values = [];
    for perm = 1:n_permutations
        if length(perm_vectors{perm}) >= dim
            dim_values(end+1) = perm_vectors{perm}(dim);
        end
    end
    dimension_distributions{dim} = dim_values;
    fprintf('  Dimension %d: %d values (%.1f%% of surrogates had >= %d clusters)\n', ...
        dim, length(dim_values), 100*length(dim_values)/n_permutations, dim);
end

%% ========================================================================
%  PART 6: CALCULATE CRITICAL VALUES
%  ========================================================================

percentile_level = 100 * (1 - alpha);

if use_vector_valued
    fprintf('\nCalculating critical values (VECTOR-VALUED, alpha = %.3f)...\n', alpha);
    
    critical_values = zeros(max_dimensions, 1);
    for dim = 1:max_dimensions
        if ~isempty(dimension_distributions{dim})
            critical_values(dim) = prctile(dimension_distributions{dim}, percentile_level);
        else
            critical_values(dim) = 0;
        end
    end
    
    % Calculate actual FWER
    n_violations = 0;
    for perm = 1:n_permutations
        perm_vec = perm_vectors{perm};
        violation = false;
        for dim = 1:min(length(perm_vec), max_dimensions)
            if perm_vec(dim) > critical_values(dim)
                violation = true;
                break;
            end
        end
        if violation
            n_violations = n_violations + 1;
        end
    end
    actual_fwer = n_violations / n_permutations;
    
    fprintf('  Actual FWER: %.4f (target: %.4f)\n', actual_fwer, alpha);
    fprintf('  Critical values per dimension:\n');
    for dim = 1:max_dimensions
        fprintf('    Dim %d: CV = %.2f (based on %d surrogate values)\n', ...
            dim, critical_values(dim), length(dimension_distributions{dim}));
    end
else
    fprintf('\nCalculating critical value (STANDARD max-stat, alpha = %.3f)...\n', alpha);
    
    if ~isempty(dimension_distributions{1})
        cv_max = prctile(dimension_distributions{1}, percentile_level);
    else
        cv_max = 0;
    end
    
    critical_values = cv_max * ones(max_dimensions, 1);
    actual_fwer = alpha;
    
    fprintf('  Critical value (from max-cluster null): %.2f\n', cv_max);
end

%% ========================================================================
%  PART 7: TEST OBSERVED CLUSTERS
%  ========================================================================

if use_vector_valued
    fprintf('\nTesting observed clusters (vector-valued)...\n');
else
    fprintf('\nTesting observed clusters (standard max-stat)...\n');
end

significant_clusters = false(max_dimensions, 1);
p_values = zeros(max_dimensions, 1);

for dim = 1:max_dimensions
    if use_vector_valued
        if ~isempty(dimension_distributions{dim})
            n_exceed = sum(dimension_distributions{dim} >= observed_vector(dim));
            p_values(dim) = n_exceed / length(dimension_distributions{dim});
        else
            p_values(dim) = 0;
        end
    else
        if ~isempty(dimension_distributions{1})
            n_exceed = sum(dimension_distributions{1} >= observed_vector(dim));
            p_values(dim) = n_exceed / length(dimension_distributions{1});
        else
            p_values(dim) = 0;
        end
    end
    
    if observed_vector(dim) > critical_values(dim)
        significant_clusters(dim) = true;
        fprintf('  Cluster %d: mass=%.2f > CV=%.2f, p=%.4f - SIGNIFICANT\n', ...
            dim, observed_vector(dim), critical_values(dim), p_values(dim));
    else
        fprintf('  Cluster %d: mass=%.2f <= CV=%.2f, p=%.4f - Not significant\n', ...
            dim, observed_vector(dim), critical_values(dim), p_values(dim));
    end
end

%% ========================================================================
%  PART 8: VISUALIZATION
%  ========================================================================

fprintf('\nGenerating visualizations...\n');

figure('Position', [100, 50, 1600, 900]);

% Panel 1: Single-trial heatmap (subset)
ax1 = subplot(3, 3, 1);
n_show = min(50, n_trials);
imagesc(time*1000, 1:n_show, trials(1:n_show, :));
hold on;
xline(trigger_time_ms, 'w--', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Trial');
title(sprintf('Single Trials (first %d)', n_show));
colormap(ax1, 'parula');
colorbar(ax1);
drawnow;  % Let MATLAB finish rendering before continuing

% Panel 2: Mean timecourse with 95% CI
subplot(3, 3, 2);
mean_tc = mean(trials, 1);
sem_tc = std(trials, 0, 1) / sqrt(n_trials);
ci95 = 1.96 * sem_tc;

t_ms = time * 1000;
fill([t_ms, fliplr(t_ms)], [mean_tc + ci95, fliplr(mean_tc - ci95)], ...
    'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold on;
plot(t_ms, mean_tc, 'b-', 'LineWidth', 2);
yline(0, 'k--', 'LineWidth', 1);
xline(trigger_time_ms, 'r--', 'LineWidth', 2);

% Mark true clusters
ylims = ylim;
patch([cluster1_time(1), cluster1_time(end), cluster1_time(end), cluster1_time(1)], ...
    [ylims(1), ylims(1), ylims(2), ylims(2)], 'g', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
patch([cluster2_time(1), cluster2_time(end), cluster2_time(end), cluster2_time(1)], ...
    [ylims(1), ylims(1), ylims(2), ylims(2)], 'g', 'FaceAlpha', 0.15, 'EdgeColor', 'none');

xlabel('Time (ms)'); ylabel('Amplitude');
title('Mean Timecourse ±95% CI (True effects = green)');
grid on;

% Panel 3: T-statistics
subplot(3, 3, 3);
plot(t_ms, observed_tvals, 'k-', 'LineWidth', 1.5); hold on;
yline(t_thresh, 'r--', 'LineWidth', 2);
yline(-t_thresh, 'r--', 'LineWidth', 2);
yline(0, 'k--', 'LineWidth', 0.5);
xline(trigger_time_ms, 'b--', 'LineWidth', 1);
xlabel('Time (ms)'); ylabel('t-value');
title(sprintf('T-statistics (threshold t=±%.2f)', t_thresh));
grid on;

% Panel 4: Example surrogate (shifted) mean
subplot(3, 3, 4);
% Apply one example surrogate shift (vectorized)
example_perm = 1;
shifts_ex = random_shifts(example_perm, :)';
shifted_col_idx_ex = mod(bsxfun(@minus, col_base, shifts_ex) - 1, n_timepoints) + 1;
linear_idx_ex = sub2ind(size(trials), row_idx, shifted_col_idx_ex);
example_shifted = trials(linear_idx_ex);
mean_shifted = mean(example_shifted, 1);
h1 = plot(t_ms, mean_tc, 'b-', 'LineWidth', 2); hold on;
h2 = plot(t_ms, mean_shifted, 'r-', 'LineWidth', 1.5);
yline(0, 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
xline(trigger_time_ms, 'k--', 'LineWidth', 1, 'HandleVisibility', 'off');
xlabel('Time (ms)'); ylabel('Amplitude');
title('Actual (blue) vs. Example Surrogate (red)');
legend([h1 h2], {'Actual', 'Surrogate'}, 'Location', 'best');
grid on;

% Panel 5: All detected clusters
subplot(3, 3, 5);
plot(t_ms, mean_tc, 'Color', [0.5 0.5 0.5], 'LineWidth', 1); hold on;
yline(0, 'k--', 'LineWidth', 0.5);
ylims = ylim;

colors = jet(length(observed_clusters_sorted));
for i = 1:length(observed_clusters_sorted)
    cluster = observed_clusters_sorted(i);
    t_start = cluster.timepoints(1);
    t_end = cluster.timepoints(end);
    
    patch([t_start, t_end, t_end, t_start], ...
        [ylims(1), ylims(1), ylims(2), ylims(2)], ...
        colors(i,:), 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'LineWidth', 1);
    
    text(mean([t_start, t_end]), ylims(2)*0.9, sprintf('%d', i), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
end
xlabel('Time (ms)'); ylabel('Amplitude');
title(sprintf('All %d Detected Clusters', length(observed_clusters_sorted)));
grid on;

% Panel 6: Significant clusters only
subplot(3, 3, 6);
plot(t_ms, mean_tc, 'k-', 'LineWidth', 2); hold on;
yline(0, 'k--', 'LineWidth', 0.5);
ylims = ylim;

for i = 1:length(observed_clusters_sorted)
    if significant_clusters(i)
        cluster = observed_clusters_sorted(i);
        t_start = cluster.timepoints(1);
        t_end = cluster.timepoints(end);
        
        patch([t_start, t_end, t_end, t_start], ...
            [ylims(1), ylims(1), ylims(2), ylims(2)], ...
            'r', 'FaceAlpha', 0.4, 'EdgeColor', 'none');
        
        text(mean([t_start, t_end]), ylims(2)*0.9, sprintf('p=%.4f', p_values(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', 'r');
    end
end
xlabel('Time (ms)'); ylabel('Amplitude');
title(sprintf('SIGNIFICANT Clusters (n=%d)', sum(significant_clusters)));
grid on;

% Panels 7-9: Dimension-specific distributions
for dim = 1:min(3, max_dimensions)
    subplot(3, 3, 6 + dim);
    
    if ~isempty(dimension_distributions{dim})
        hHist = histogram(dimension_distributions{dim}, 50, ...
            'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'k', 'Normalization', 'probability');
        hold on;
        
        yl = ylim;
        hCV = plot([critical_values(dim), critical_values(dim)], yl, 'r--', 'LineWidth', 2.5);
        hObs = plot([observed_vector(dim), observed_vector(dim)], yl, 'b-', 'LineWidth', 2.5);
        
        xlabel('Absolute Cluster Mass');
        ylabel('Probability');
        
        sig_str = '';
        if significant_clusters(dim)
            sig_str = ' - SIG';
        end
        title(sprintf('Dim %d: p=%.4f%s', dim, p_values(dim), sig_str));
        legend([hHist hCV hObs], {'Null', 'CV', 'Observed'}, 'Location', 'best');
        grid on;
    end
end

sgtitle('Surrogate Trigger Test: Is Modulation Time-Locked to R-peak?', ...
    'FontSize', 16, 'FontWeight', 'bold');

%% ========================================================================
%  PART 9: SUMMARY
%  ========================================================================

fprintf('\n================================================================================\n');
fprintf('SUMMARY: SURROGATE TRIGGER TEST\n');
fprintf('================================================================================\n');
fprintf('Parameters:\n');
fprintf('  Trials: %d\n', n_trials);
fprintf('  Trigger at: %d ms\n', trigger_time_ms);
fprintf('  Surrogate method: circular shift (uniform 0-%d ms)\n', n_timepoints);
fprintf('  Minimum cluster size: %d samples\n', min_cluster_size);
fprintf('  Alpha: %.3f\n', alpha);
if use_vector_valued
    fprintf('  Inference: Vector-valued (Section 4.5)\n');
else
    fprintf('  Inference: Standard (max-stat)\n');
end
fprintf('  Actual FWER: %.4f\n', actual_fwer);
fprintf('--------------------------------------------------------------------------------\n');
fprintf('Cluster | Time Range (ms) | Size | Mass    | CV      | p-value | Significant\n');
fprintf('--------|-----------------|------|---------|---------|---------|------------\n');

for i = 1:length(observed_clusters_sorted)
    cluster = observed_clusters_sorted(i);
    if significant_clusters(i)
        sig_str = 'YES';
    else
        sig_str = 'NO';
    end
    fprintf('   %2d   |   %3d - %3d     | %4d | %7.1f | %7.1f | %.5f |     %s\n', ...
        i, cluster.timepoints(1), cluster.timepoints(end), cluster.size, ...
        observed_vector(i), critical_values(i), p_values(i), sig_str);
end

fprintf('================================================================================\n');
fprintf('Conclusion: %d of %d clusters show significant time-locking to trigger\n', ...
    sum(significant_clusters), length(observed_clusters_sorted));
fprintf('================================================================================\n\n');

%% ========================================================================
%  HELPER FUNCTIONS
%  ========================================================================

function [clusters, tvals, n_before_filter] = calculate_cluster_stats_one_sample(...
    trials, min_cluster_size, smooth_t_samples, cluster_p_thresh)
    % One-sample t-test at each time point (is mean ≠ 0?)
    % Uses bwconncomp for efficient cluster detection
    
    n_trials = size(trials, 1);
    
    % Vectorized one-sample t-test
    trial_mean = mean(trials, 1);
    trial_std = std(trials, 0, 1);
    trial_se = trial_std / sqrt(n_trials);
    tvals = trial_mean ./ trial_se;
    
    % Optional smoothing
    if smooth_t_samples > 0
        tvals_for_thresh = smoothdata(tvals, 'gaussian', smooth_t_samples);
    else
        tvals_for_thresh = tvals;
    end
    
    % Threshold
    df = n_trials - 1;
    t_thresh = tinv(1 - cluster_p_thresh/2, df);
    
    % Find clusters using bwconncomp
    [clusters, n_before_filter] = find_clusters_from_tvals(tvals, tvals_for_thresh, t_thresh, min_cluster_size);
end

function [clusters, n_before_filter] = find_clusters_from_tvals(tvals, tvals_for_thresh, t_thresh, min_cluster_size)
    % Find clusters from pre-computed t-values using bwconncomp (vectorized)
    
    % Get positive and negative clusters
    pos_mask = tvals_for_thresh > t_thresh;
    neg_mask = tvals_for_thresh < -t_thresh;
    
    % Use bwconncomp for efficient connected component labeling
    CC_pos = bwconncomp(pos_mask);
    CC_neg = bwconncomp(neg_mask);
    
    n_before_filter = CC_pos.NumObjects + CC_neg.NumObjects;
    
    % Combine all pixel lists
    all_pix = [CC_pos.PixelIdxList, CC_neg.PixelIdxList];
    
    if isempty(all_pix)
        clusters = struct('timepoints', {}, 'mass', {}, 'size', {});
        return;
    end
    
    % Vectorized: compute sizes and masses for all clusters at once
    sizes = cellfun(@length, all_pix);
    masses = cellfun(@(idx) sum(tvals(idx)), all_pix);
    
    % Filter by minimum size (vectorized)
    keep = sizes >= min_cluster_size;
    
    % Build output struct array
    n_keep = sum(keep);
    if n_keep == 0
        clusters = struct('timepoints', {}, 'mass', {}, 'size', {});
        return;
    end
    
    kept_pix = all_pix(keep);
    kept_sizes = sizes(keep);
    kept_masses = masses(keep);
    
    % Pre-allocate struct array
    clusters(n_keep) = struct('timepoints', [], 'mass', [], 'size', []);
    for i = 1:n_keep
        clusters(i).timepoints = kept_pix{i}(:)';  % Row vector of indices
        clusters(i).mass = kept_masses(i);
        clusters(i).size = kept_sizes(i);
    end
end
