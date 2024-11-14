function testsim_cluster_perm_vs_shuffled

% Simulation Parameters
time_bins = 25;
freq_bins = 20;
n_permutations = 100;  % Number of permutations
threshold = 2.58;  % More stringent threshold (z-score equivalent to p < 0.01)

noise_level = 1;
signal_level = 1;

% Step 1: Simulate Actual Data with a Cluster of High Power
actual_data = noise_level*randn(time_bins, freq_bins);  % Background noise
actual_data(10:15, 8:12) = actual_data(10:15, 8:12) + signal_level;  % Add "signal" cluster

% Step 2: Simulate Shuffled Data (random noise)
shuffled_data = noise_level*randn(n_permutations, time_bins, freq_bins);

% Step 3: Compute t-statistics for actual data vs. shuffled data mean
shuffled_mean = mean(shuffled_data, 1);  % Mean over permutations
shuffled_std = std(shuffled_data, 0, 1); % Standard deviation over permutations

% Ensure the dimensions of shuffled_mean and shuffled_std are (time_bins, freq_bins)
shuffled_mean = squeeze(shuffled_mean);
shuffled_std = squeeze(shuffled_std);

% Calculate t-values for each time-frequency bin
t_values = (actual_data - shuffled_mean) ./ (shuffled_std / sqrt(n_permutations));

% Step 4: Identify clusters in the actual data
actual_clusters = bwlabel(t_values > threshold);  % Binary label of clusters
n_actual_clusters = max(actual_clusters(:));

% Step 5: Calculate actual cluster statistics (sum of t-values within each cluster)
actual_cluster_stats = zeros(n_actual_clusters, 1);
for c = 1:n_actual_clusters
    actual_cluster_stats(c) = sum(t_values(actual_clusters == c));
end

% Step 6: Permutation testing
null_distribution = zeros(n_permutations, 1);
for perm = 1:n_permutations
    % Compute t-values for this permutation
    perm_data = squeeze(shuffled_data(perm, :, :));
    perm_t_values = (perm_data - shuffled_mean) ./ (shuffled_std / sqrt(n_permutations));
    
    % Identify clusters in permutation data
    perm_clusters = bwlabel(perm_t_values > threshold);
    n_perm_clusters = max(perm_clusters(:));
    
    % Compute maximum cluster statistic for this permutation
    max_perm_cluster_stat = 0;
    for c = 1:n_perm_clusters
        cluster_stat = sum(perm_t_values(perm_clusters == c));
        if cluster_stat > max_perm_cluster_stat
            max_perm_cluster_stat = cluster_stat;
        end
    end
    null_distribution(perm) = max_perm_cluster_stat;
end

% Step 7: Calculate p-values for actual clusters
p_values = zeros(n_actual_clusters, 1);
for c = 1:n_actual_clusters
    p_values(c) = mean(null_distribution >= actual_cluster_stats(c));
end

% Step 8: Identify significant clusters (e.g., p < 0.05)
significant_clusters = ismember(actual_clusters, find(p_values < 0.05));

% Determine color limits based on data range in both actual and shuffled mean data
color_limits = [min(min(actual_data(:)), min(shuffled_mean(:))), ...
    max(max(actual_data(:)), max(shuffled_mean(:)))];

% Visualization: Plot actual_data with outline around significant clusters
figure;
subplot(1, 2, 1);  % Create a 1x2 subplot layout
h = imagesc(1:freq_bins, 1:time_bins, actual_data);  % Plot actual data
colormap(jet);
colorbar;
caxis(color_limits);  % Set color scale to be the same for both plots
hold on;

% % Overlay significant clusters as an outline
% for c = significant_clusters'
%     [rows, cols] = find(actual_clusters == c);
%     k = convhull(cols, rows);  % Find convex hull for the cluster points
%     plot(cols(k), rows(k), 'k-', 'LineWidth', 2);  % Outline significant clusters
% end


% Apply 50% transparency to nonsignificant bins by setting their color to a pale shade
alpha_data = 0.5 * ones(size(actual_data));  % Initialize all bins with 50% transparency
alpha_data(significant_clusters) = 1;        % Keep significant clusters opaque
set(h, 'AlphaData', alpha_data);

% % Overlay white edges on significant bins
% [signif_y, signif_x] = find(significant_clusters);
% for k = 1:length(signif_x)
%     rectangle('Position', [signif_x(k)-0.5, signif_y(k)-0.5, 1, 1], ...
%               'EdgeColor', 'w', 'LineWidth', 1.5);
% end

plotRegionBoundaries(alpha_data==1);


title('Actual Data with Significant Clusters');
xlabel('Time Bins');
ylabel('Frequency Bins');

% Plot mean of shuffled data
subplot(1, 2, 2);
imagesc(1:freq_bins, 1:time_bins, shuffled_mean);  % Plot mean of shuffled data
colormap(jet);
colorbar;
caxis(color_limits);  % Use the same color scale
title('Mean of Shuffled Data');
xlabel('Time Bins');
ylabel('Frequency Bins');


function plotRegionBoundaries(matrix)
% Get matrix dimensions
[rows, cols] = size(matrix);

% Create figure and display binary matrix
% figure;
% imagesc(matrix);
% colormap([1 1 1; 0 0 1]); % White background, blue regions
% axis equal tight;
hold on;

% Create extended matrix with padding to help detect edges
padded = zeros(rows+2, cols+2);
padded(2:end-1, 2:end-1) = matrix;

% Initialize arrays to store line segments
x = [];
y = [];

% Scan for horizontal edges
for i = 1:rows
    for j = 1:cols
        if matrix(i,j) == 1
            % Check top edge
            if i == 1 || matrix(i-1,j) == 0
                x = [x, j-0.5, j+0.5, NaN];
                y = [y, i-0.5, i-0.5, NaN];
            end
            % Check bottom edge
            if i == rows || matrix(i+1,j) == 0
                x = [x, j-0.5, j+0.5, NaN];
                y = [y, i+0.5, i+0.5, NaN];
            end
        end
    end
end

% Scan for vertical edges
for j = 1:cols
    for i = 1:rows
        if matrix(i,j) == 1
            % Check left edge
            if j == 1 || matrix(i,j-1) == 0
                x = [x, j-0.5, j-0.5, NaN];
                y = [y, i-0.5, i+0.5, NaN];
            end
            % Check right edge
            if j == cols || matrix(i,j+1) == 0
                x = [x, j+0.5, j+0.5, NaN];
                y = [y, i-0.5, i+0.5, NaN];
            end
        end
    end
end

% Plot all edges at once
plot(x, y, 'k', 'LineWidth', 2);

% Add title and adjust appearance
title('Binary Regions with Boundaries');
grid off;


