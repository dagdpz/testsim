% testsim_cluster_perm_ITPC_vs_surrogate
% Cluster-based permutation test for single-value timecourses (e.g., ITPC)
% Tests if observed timecourse is significantly different from surrogate distribution
%
% Scenario:
%   - Observed: ONE timecourse (e.g., ITPC computed across all trials)
%   - Surrogates: K timecourses (e.g., ITPC from circularly-shifted trials)
%   - No trial-by-trial data available → use z-scores instead of t-statistics
%
% Statistic: z-score at each timepoint
%   z(t) = (observed(t) - mean(surrogates(:,t))) / std(surrogates(:,t))
%
% Null distribution: Treat each surrogate as "pseudo-observed" in turn

clear; close all; rng(42);

%% ========================================================================
%  PART 1: PARAMETERS
%  ========================================================================

fprintf('Setting up ITPC surrogate test...\n');

% Timecourse structure
n_timepoints = 1000;       % Time points (e.g., 1000ms at 1000Hz)
sampling_rate = 1000;      % Hz
time = (0:n_timepoints-1) / sampling_rate;  % Time in seconds
trigger_time_ms = 500;     % R-peak location (ms)

% Number of surrogates (= number of permutations for null)
n_surrogates = 1000;

% MINIMUM CLUSTER SIZE
min_cluster_size = 5;      % Minimum samples to be considered a cluster

% CLUSTER-FORMING THRESHOLD (z-score)
z_thresh = 1.96;           % Two-sided p < 0.05

% Optional: use percentile threshold instead of fixed z
use_percentile_thresh = false;  % If true, use 2.5/97.5 percentiles
percentile_thresh = 2.5;        % For two-sided test

% Z-VALUE SMOOTHING
smooth_z_ms = 0;           % Gaussian smoothing of z-values (ms), 0 to disable
smooth_z_samples = round(smooth_z_ms * sampling_rate / 1000);

% Family-wise error rate
alpha = 0.05;

% INFERENCE METHOD
use_vector_valued = false;  % true: dimension-specific nulls (Section 4.5)
                           % false: max-stat only

fprintf('  Timepoints: %d\n', n_timepoints);
fprintf('  Surrogates: %d\n', n_surrogates);
fprintf('  Trigger at: %d ms\n', trigger_time_ms);
fprintf('  Minimum cluster size: %d samples\n', min_cluster_size);
fprintf('  Cluster-forming threshold: |z| > %.2f\n', z_thresh);
if use_vector_valued
    fprintf('  Inference: Vector-valued (Section 4.5)\n');
else
    fprintf('  Inference: Standard (max-stat only)\n');
end

%% ========================================================================
%  PART 2: SIMULATE DATA (mimicking ITPC-like metric)
%  ========================================================================

fprintf('\nGenerating simulated ITPC-like data...\n');

% Background noise level (baseline ITPC fluctuation)
baseline_mean = 0.3;       % Typical ITPC baseline
baseline_std = 0.05;       % Fluctuation around baseline

% Generate baseline for observed (smooth random walk)
observed = baseline_mean + baseline_std * cumsum(randn(1, n_timepoints)) / sqrt(n_timepoints);
observed = smoothdata(observed, 'gaussian', 50);  % Smooth to make realistic
observed = observed - mean(observed) + baseline_mean;  % Re-center

% Add TRUE EFFECTS (time-locked ITPC increases)
% CLUSTER 1: 550-650 ms (50-150 ms post-trigger) - strong effect
cluster1_time = 550:650;
cluster1_effect = 0.15;  % ITPC increase
observed(cluster1_time) = observed(cluster1_time) + cluster1_effect;

% CLUSTER 2: 750-800 ms (250-300 ms post-trigger) - weaker effect
cluster2_time = 750:800;
cluster2_effect = 0.08;  % Smaller ITPC increase
observed(cluster2_time) = observed(cluster2_time) + cluster2_effect;

fprintf('  True effect clusters (relative to trigger at %d ms):\n', trigger_time_ms);
fprintf('    Cluster 1: %d-%d ms (ITPC increase: %.2f)\n', ...
    cluster1_time(1), cluster1_time(end), cluster1_effect);
fprintf('    Cluster 2: %d-%d ms (ITPC increase: %.2f)\n', ...
    cluster2_time(1), cluster2_time(end), cluster2_effect);

% Generate surrogates (no time-locked effect, just baseline fluctuations)
% In real data: these would come from circularly-shifted trials
surrogates = zeros(n_surrogates, n_timepoints);
for k = 1:n_surrogates
    surrogates(k,:) = baseline_mean + baseline_std * cumsum(randn(1, n_timepoints)) / sqrt(n_timepoints);
    surrogates(k,:) = smoothdata(surrogates(k,:), 'gaussian', 50);
    surrogates(k,:) = surrogates(k,:) - mean(surrogates(k,:)) + baseline_mean;
end

fprintf('  Observed ITPC: mean=%.3f, std=%.3f\n', mean(observed), std(observed));
fprintf('  Surrogate ITPC: mean=%.3f, std=%.3f\n', mean(surrogates(:)), std(surrogates(:)));

%% ========================================================================
%  PART 3: CALCULATE OBSERVED Z-SCORES
%  ========================================================================

fprintf('\nCalculating observed z-scores...\n');

% Z-score at each timepoint: how far is observed from surrogate distribution?
surr_mean = mean(surrogates, 1);  % [1 × n_timepoints]
surr_std = std(surrogates, 0, 1); % [1 × n_timepoints]

% Avoid division by zero
surr_std(surr_std < eps) = eps;

z_observed = (observed - surr_mean) ./ surr_std;

% Optional smoothing
if smooth_z_samples > 0
    z_observed_thresh = smoothdata(z_observed, 'gaussian', smooth_z_samples);
else
    z_observed_thresh = z_observed;
end

fprintf('  Z-score range: [%.2f, %.2f]\n', min(z_observed), max(z_observed));

% Find clusters in observed data
if use_percentile_thresh
    % Use percentile-based threshold
    thresh_pos = prctile(surrogates, 100 - percentile_thresh, 1);
    thresh_neg = prctile(surrogates, percentile_thresh, 1);
    pos_mask = observed > thresh_pos;
    neg_mask = observed < thresh_neg;
else
    % Use fixed z-threshold
    pos_mask = z_observed_thresh > z_thresh;
    neg_mask = z_observed_thresh < -z_thresh;
end

[observed_clusters, n_before_filter] = find_clusters_from_mask(pos_mask, neg_mask, z_observed, min_cluster_size);

fprintf('  Detected %d clusters before size filter\n', n_before_filter);
fprintf('  Retained %d clusters after size filter (>= %d samples)\n', ...
    length(observed_clusters), min_cluster_size);

if isempty(observed_clusters)
    warning('No clusters found in observed data! Try lowering min_cluster_size or z_thresh.');
    return;
end

% Sort by absolute cluster mass
[observed_vector, sort_idx] = sort(abs([observed_clusters.mass]), 'descend');
observed_clusters_sorted = observed_clusters(sort_idx);

fprintf('  Observed cluster masses (sorted): ');
fprintf('%.1f ', observed_vector);
fprintf('\n');

%% ========================================================================
%  PART 4: BUILD NULL DISTRIBUTION (each surrogate as pseudo-observed)
%  ========================================================================

fprintf('\nBuilding null distribution from %d surrogates...\n', n_surrogates);

perm_vectors = cell(n_surrogates, 1);
debug_clusters_before = zeros(n_surrogates, 1);
debug_clusters_after = zeros(n_surrogates, 1);

for k = 1:n_surrogates
    % Treat surrogate k as "observed"
    pseudo_obs = surrogates(k, :);
    
    % Z-score against ALL surrogates (including itself - bias negligible with large K)
    z_pseudo = (pseudo_obs - surr_mean) ./ surr_std;
    
    % Optional smoothing
    if smooth_z_samples > 0
        z_pseudo_thresh = smoothdata(z_pseudo, 'gaussian', smooth_z_samples);
    else
        z_pseudo_thresh = z_pseudo;
    end
    
    % Find clusters
    if use_percentile_thresh
        pos_mask_k = pseudo_obs > thresh_pos;
        neg_mask_k = pseudo_obs < thresh_neg;
    else
        pos_mask_k = z_pseudo_thresh > z_thresh;
        neg_mask_k = z_pseudo_thresh < -z_thresh;
    end
    
    [clusters_k, n_before] = find_clusters_from_mask(pos_mask_k, neg_mask_k, z_pseudo, min_cluster_size);
    
    debug_clusters_before(k) = n_before;
    debug_clusters_after(k) = length(clusters_k);
    
    if ~isempty(clusters_k)
        perm_vectors{k} = sort(abs([clusters_k.mass]), 'descend');
    else
        perm_vectors{k} = [];
    end
end

fprintf('  DEBUG: Null cluster stats:\n');
fprintf('    Clusters before size filter: mean=%.1f, max=%d\n', ...
    mean(debug_clusters_before), max(debug_clusters_before));
fprintf('    Clusters after size filter: mean=%.1f, max=%d\n', ...
    mean(debug_clusters_after), max(debug_clusters_after));
fprintf('    Surrogates with >=1 cluster: %d (%.1f%%)\n', ...
    sum(debug_clusters_after >= 1), 100*sum(debug_clusters_after >= 1)/n_surrogates);

%% ========================================================================
%  PART 5: BUILD DIMENSION-SPECIFIC DISTRIBUTIONS
%  ========================================================================

fprintf('\nBuilding dimension-specific distributions...\n');

max_dimensions = length(observed_vector);
fprintf('  Number of observed clusters (dimensions): %d\n', max_dimensions);

dimension_distributions = cell(max_dimensions, 1);

for dim = 1:max_dimensions
    dim_values = zeros(1, n_surrogates);  % All start at 0
    n_with_clusters = 0;
    for k = 1:n_surrogates
        if length(perm_vectors{k}) >= dim
            dim_values(k) = perm_vectors{k}(dim);
            n_with_clusters = n_with_clusters + 1;
        end
        % else: stays 0 (no cluster at this dimension under null)
    end
    dimension_distributions{dim} = dim_values;
    fprintf('  Dimension %d: %d/%d surrogates (%.1f%%) had >= %d clusters\n', ...
        dim, n_with_clusters, n_surrogates, 100*n_with_clusters/n_surrogates, dim);
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
    for k = 1:n_surrogates
        perm_vec = perm_vectors{k};
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
    actual_fwer = n_violations / n_surrogates;
    
    fprintf('  Actual FWER: %.4f (target: %.4f)\n', actual_fwer, alpha);
    fprintf('  Critical values per dimension:\n');
    for dim = 1:max_dimensions
        fprintf('    Dim %d: CV = %.2f\n', dim, critical_values(dim));
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

% Panel 1: Surrogate distribution (heatmap of subset)
ax1 = subplot(3, 3, 1);
n_show = min(100, n_surrogates);
imagesc(time*1000, 1:n_show, surrogates(1:n_show, :));
hold on;
xline(trigger_time_ms, 'w--', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Surrogate #');
title(sprintf('Surrogate Timecourses (first %d of %d)', n_show, n_surrogates));
colormap(ax1, 'parula');
cb = colorbar(ax1);
ylabel(cb, 'ITPC');
drawnow;

% Panel 2: Observed vs surrogate mean
subplot(3, 3, 2);
surr_ci = 1.96 * surr_std;
t_ms = time * 1000;

fill([t_ms, fliplr(t_ms)], [surr_mean + surr_ci, fliplr(surr_mean - surr_ci)], ...
    [0.7 0.7 0.7], 'FaceAlpha', 0.5, 'EdgeColor', 'none'); hold on;
plot(t_ms, surr_mean, 'k-', 'LineWidth', 1);
plot(t_ms, observed, 'b-', 'LineWidth', 2);
xline(trigger_time_ms, 'r--', 'LineWidth', 2);

% Mark true clusters
ylims = ylim;
patch([cluster1_time(1), cluster1_time(end), cluster1_time(end), cluster1_time(1)], ...
    [ylims(1), ylims(1), ylims(2), ylims(2)], 'g', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
patch([cluster2_time(1), cluster2_time(end), cluster2_time(end), cluster2_time(1)], ...
    [ylims(1), ylims(1), ylims(2), ylims(2)], 'g', 'FaceAlpha', 0.15, 'EdgeColor', 'none');

xlabel('Time (ms)'); ylabel('ITPC');
title('Observed (blue) vs Surrogate Mean ±95% CI (gray)');
legend({'Surrogate 95% CI', 'Surrogate mean', 'Observed', 'Trigger'}, 'Location', 'best');
grid on;

% Panel 3: Z-statistics
subplot(3, 3, 3);
plot(t_ms, z_observed, 'k-', 'LineWidth', 1.5); hold on;
yline(z_thresh, 'r--', 'LineWidth', 2);
yline(-z_thresh, 'r--', 'LineWidth', 2);
yline(0, 'k--', 'LineWidth', 0.5);
xline(trigger_time_ms, 'b--', 'LineWidth', 1);
xlabel('Time (ms)'); ylabel('z-score');
title(sprintf('Z-statistics (threshold z=±%.2f)', z_thresh));
grid on;

% Panel 4: Example surrogate z-scores
subplot(3, 3, 4);
example_k = 1;
z_example = (surrogates(example_k,:) - surr_mean) ./ surr_std;
plot(t_ms, z_observed, 'b-', 'LineWidth', 2); hold on;
plot(t_ms, z_example, 'r-', 'LineWidth', 1.5);
yline(z_thresh, 'k--', 'LineWidth', 1, 'HandleVisibility', 'off');
yline(-z_thresh, 'k--', 'LineWidth', 1, 'HandleVisibility', 'off');
yline(0, 'k--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
xlabel('Time (ms)'); ylabel('z-score');
title('Observed z (blue) vs. Example Surrogate z (red)');
legend({'Observed', 'Surrogate'}, 'Location', 'best');
grid on;

% Panel 5: All detected clusters
subplot(3, 3, 5);
plot(t_ms, observed, 'Color', [0.5 0.5 0.5], 'LineWidth', 1); hold on;
ylims = ylim;

colors = jet(length(observed_clusters_sorted));
for i = 1:length(observed_clusters_sorted)
    cluster = observed_clusters_sorted(i);
    t_start = cluster.timepoints(1);
    t_end = cluster.timepoints(end);
    
    patch([t_start, t_end, t_end, t_start], ...
        [ylims(1), ylims(1), ylims(2), ylims(2)], ...
        colors(i,:), 'FaceAlpha', 0.4, 'EdgeColor', 'k', 'LineWidth', 1);
    
    text(mean([t_start, t_end]), ylims(2)*0.95, sprintf('%d', i), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
end
xlabel('Time (ms)'); ylabel('ITPC');
title(sprintf('All %d Detected Clusters', length(observed_clusters_sorted)));
grid on;

% Panel 6: Significant clusters only
subplot(3, 3, 6);
plot(t_ms, observed, 'k-', 'LineWidth', 2); hold on;
ylims = ylim;

for i = 1:length(observed_clusters_sorted)
    if significant_clusters(i)
        cluster = observed_clusters_sorted(i);
        t_start = cluster.timepoints(1);
        t_end = cluster.timepoints(end);
        
        patch([t_start, t_end, t_end, t_start], ...
            [ylims(1), ylims(1), ylims(2), ylims(2)], ...
            'r', 'FaceAlpha', 0.4, 'EdgeColor', 'none');
        
        text(mean([t_start, t_end]), ylims(2)*0.95, sprintf('p=%.4f', p_values(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', 'r');
    end
end
xlabel('Time (ms)'); ylabel('ITPC');
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
        
        xlabel('Absolute Cluster Mass (sum of z)');
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

sgtitle('ITPC Surrogate Test: Is Modulation Time-Locked?', ...
    'FontSize', 16, 'FontWeight', 'bold');

%% ========================================================================
%  PART 9: SUMMARY
%  ========================================================================

fprintf('\n================================================================================\n');
fprintf('SUMMARY: ITPC SURROGATE TEST\n');
fprintf('================================================================================\n');
fprintf('Parameters:\n');
fprintf('  Timepoints: %d\n', n_timepoints);
fprintf('  Surrogates: %d\n', n_surrogates);
fprintf('  Trigger at: %d ms\n', trigger_time_ms);
fprintf('  Statistic: z-score (observed vs surrogate distribution)\n');
fprintf('  Cluster-forming threshold: |z| > %.2f\n', z_thresh);
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
fprintf('Conclusion: %d of %d clusters show significant time-locking\n', ...
    sum(significant_clusters), length(observed_clusters_sorted));
fprintf('================================================================================\n\n');

%% ========================================================================
%  HELPER FUNCTION
%  ========================================================================

function [clusters, n_before_filter] = find_clusters_from_mask(pos_mask, neg_mask, zvals, min_cluster_size)
    % Find clusters from binary masks using bwconncomp
    
    CC_pos = bwconncomp(pos_mask);
    CC_neg = bwconncomp(neg_mask);
    
    n_before_filter = CC_pos.NumObjects + CC_neg.NumObjects;
    
    all_pix = [CC_pos.PixelIdxList, CC_neg.PixelIdxList];
    
    if isempty(all_pix)
        clusters = struct('timepoints', {}, 'mass', {}, 'size', {});
        return;
    end
    
    % Compute sizes and masses
    sizes = cellfun(@length, all_pix);
    masses = cellfun(@(idx) sum(zvals(idx)), all_pix);
    
    % Filter by minimum size
    keep = sizes >= min_cluster_size;
    
    n_keep = sum(keep);
    if n_keep == 0
        clusters = struct('timepoints', {}, 'mass', {}, 'size', {});
        return;
    end
    
    kept_pix = all_pix(keep);
    kept_sizes = sizes(keep);
    kept_masses = masses(keep);
    
    % Build output struct array
    clusters(n_keep) = struct('timepoints', [], 'mass', [], 'size', []);
    for i = 1:n_keep
        clusters(i).timepoints = kept_pix{i}(:)';
        clusters(i).mass = kept_masses(i);
        clusters(i).size = kept_sizes(i);
    end
end
