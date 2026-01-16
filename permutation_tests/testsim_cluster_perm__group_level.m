function testsim_cluster_perm__group_level
% testsim_cluster_perm__group_level
%
% PAIRED (within-site) GROUP-LEVEL CLUSTER PERMUTATION TEST (simple + systematic)
%
% Goal
% - You have multiple independent sites. For each site you computed a time-frequency (TF) map
%   aligned to the REAL R-peak ("actual") and also TF maps aligned to DITHERED R-peaks ("surrogates").
% - You want significant TF CLUSTERS across sites, corrected for multiple comparisons over the TF grid.
%
% What you have as input (conceptually)
% - For each site s:
%     - 1 actual TF map:      A(:,:,s)
%     - (K-1) surrogate maps: S(:,:,s,1..K-1)
%   In this demo we store both together as maps(:,:,s,1..K) where index 1 is actual.
%
% What we test
% - Null hypothesis: the real R-peak alignment is NOT special.
%   Under this null, "actual" is exchangeable with the surrogate alignments within the same site.
%   In plain terms: if the effect is not heartbeat-locked, picking the true R-peak vs a dither
%   should not systematically change the TF map.
%
% One map per site goes into the group statistic
% - Even though each site has K maps stored, the group statistic always uses ONE derived map per site:
%     D(:,:,s) = chosen_map(:,:,s) - mean_of_other_maps(:,:,s)
%
% Step-by-step algorithm
% 1) Build the observed site-level effect maps:
%      D_obs(:,:,s) = A(:,:,s) - mean(S(:,:,s,:))
%
% 2) Compute the observed group t-map across sites:
%      For each TF bin (t,f), do a one-sample t-test across sites on D_obs(t,f,1..S).
%      This yields t_obs(t,f).
%
% 3) Cluster the observed group t-map:
%      - Threshold t_obs at a cluster-forming threshold CLUSTER_P (two-sided).
%      - Find connected components (clusters) separately for positive and negative bins.
%      - Compute a cluster statistic (cluster mass) as sum(t) over bins in the cluster.
%
% 4) Build the permutation null distribution (this is the key "paired" part):
%      Repeat N_PERMS times:
%        a) For each site s, randomly pick ONE of its K maps to act as "pseudo-actual".
%        b) For that site, form D_perm(:,:,s) = pseudo_actual - mean(other K-1 maps).
%        c) Compute the group t-map t_perm from D_perm across sites.
%        d) Threshold+cluster t_perm and record ONLY the largest positive cluster mass
%           and the most negative cluster mass for this permutation.
%      This gives a max-cluster null distribution that controls the family-wise error rate (FWER).
%
% 5) Compute cluster p-values:
%      - For each observed positive cluster: p = fraction of permutations whose max positive cluster
%        mass is >= the observed cluster mass.
%      - For each observed negative cluster: p = fraction of permutations whose most-negative cluster
%        mass is <= the observed cluster mass.
%      Mark clusters significant if p < ALPHA.
%
% Requires Image Processing Toolbox for bwconncomp / imfill.

% -------------------- CONFIG --------------------
RNG_SEED = 1;            % [] to not set RNG

T = 50;                  % time bins
F = 50;                  % freq bins
S = 30;                  % number of sites
K = 101;                 % 1 actual + 100 surrogate alignments per site

N_PERMS = 1000;          % group-level permutations
ALPHA = 0.01;            % cluster-level alpha (FWER via max-cluster null)
CLUSTER_P = 0.05;        % cluster-forming threshold (two-sided p)
CONN = 8;                % 4: no diagonal touching merge; 8: diagonal merges
FILL_HOLES = false;      % fill holes inside supra-threshold clusters

% How each TF map is generated (3 layers, from "most shared" to "most random"):
%
% 1) global_background_sd:
%    - ONE 2D pattern shared by EVERY site and EVERY alignment.
%    - Think: a common 1/f shape or common band power that everybody has.
%    - Bigger value => all sites look more similar (because they share more of the same structure).
%
% 2) site_deviation_sd:
%    - ONE 2D pattern per site, shared across that site's K alignments.
%    - Think: each site has its own stable "fingerprint".
%    - Bigger value => sites differ more from each other, but each site is still consistent across alignments.
%
% 3) alignment_jitter_sd:
%    - Fresh noise for every site AND every alignment (actual + each dither).
%    - Think: run-to-run variability from finite data, noise, etc.
%    - Bigger value => the 101 maps within one site differ more from each other.
global_background_sd = 0.5;
site_deviation_sd = 0.5;
alignment_jitter_sd = 1.0;

% Effect patches (same style as testsim_cluster_perm_vs_shuffled_paired)
effect_strength = [-2 3 4 4];
effect_time = [3 8; 10 20; 25 30; 40 47];
effect_freq = [3 8; 10 20; 15 25; 30 33];
site_effect_jitter_sd = 0.25; % site-to-site jitter on effect amplitude
% ------------------------------------------------

if ~isempty(RNG_SEED)
    rng(RNG_SEED);
end

assert(K >= 2, 'K must be >= 2 (1 actual + at least 1 surrogate).');
assert(size(effect_time,1) == numel(effect_strength), 'effect_time rows must match effect_strength.');
assert(size(effect_freq,1) == numel(effect_strength), 'effect_freq rows must match effect_strength.');

% -------------------- SIMULATE DATA --------------------
% We store ALL maps in one 4D array:
% maps(time, freq, site, alignment)
% alignment=1 is "actual", alignment=2..K are "surrogates".
maps = zeros(T, F, S, K);

% Step 1: global background shared by everyone
global_background = global_background_sd * randn(T, F);

% Step 2: site-specific deviation (fingerprint), shared across alignments within a site
site_deviation = site_deviation_sd * randn(T, F, S);

% Step 3: build all alignments as background + site fingerprint + per-alignment jitter
maps = global_background + site_deviation + alignment_jitter_sd * randn(T, F, S, K);

% Step 4: inject an effect only into the actual alignment (alignment=1)
for p = 1:numel(effect_strength)
    t_idx = effect_time(p,1):effect_time(p,2);
    f_idx = effect_freq(p,1):effect_freq(p,2);

    jitter = site_effect_jitter_sd * randn(1, 1, S);
    amp = reshape(effect_strength(p) + jitter, [1 1 S]);

    maps(t_idx, f_idx, :, 1) = maps(t_idx, f_idx, :, 1) + amp;
end

% Precompute sum over alignments per site: used to compute "mean of the other (K-1)"
sum_all = sum(maps, 4); % [T x F x S]

% -------------------- OBSERVED EFFECT MAPS --------------------
% Step 4 (observed): build ONE 2D effect map per site:
% D_obs(:,:,site) = actual(:,:,site) - mean(surrogates(:,:,site,:))
mean_surr = (sum_all - maps(:,:,:,1)) ./ (K - 1);
D_obs = maps(:,:,:,1) - mean_surr; % [T x F x S]

% Step 5 (observed): compute the group t-map across sites and find observed clusters
[t_obs, clusters_obs, cluster_mass_obs, is_pos_cluster_obs, pos_mask_obs, neg_mask_obs] = ...
    group_tmap_and_clusters(D_obs, CLUSTER_P, CONN, FILL_HOLES);

% -------------------- PERMUTATION NULL --------------------
null_max_pos = zeros(N_PERMS, 1);
null_min_neg = zeros(N_PERMS, 1);

for perm = 1:N_PERMS
    % Step 6 (permutation): for each site pick which alignment is treated as "actual"
    chosen = randi(K, [S, 1]); % chosen(s) in 1..K

    % Step 7 (permutation): build ONE effect map per site for this permutation
    % D_perm(:,:,site) = chosen_map - mean(other_maps)
    D_perm = zeros(T, F, S);
    for s = 1:S
        chosen_map = maps(:,:,s, chosen(s));
        mean_others = (sum_all(:,:,s) - chosen_map) ./ (K - 1);
        D_perm(:,:,s) = chosen_map - mean_others;
    end

    % Step 8 (permutation): compute group t-map and find clusters
    [t_perm, ~, ~, ~, pos_mask_perm, neg_mask_perm] = ...
        group_tmap_and_clusters(D_perm, CLUSTER_P, CONN, FILL_HOLES);

    % Step 9 (permutation): keep the strongest positive/negative cluster mass
    null_max_pos(perm) = max_cluster_mass(t_perm, pos_mask_perm, CONN);
    null_min_neg(perm) = min_cluster_mass(t_perm, neg_mask_perm, CONN);
end

% -------------------- CLUSTER P-VALUES --------------------
n_clusters = numel(clusters_obs);
p_cluster = ones(n_clusters, 1);
for i = 1:n_clusters
    % Step 10: cluster p-value = fraction of permutations with a stronger cluster
    if is_pos_cluster_obs(i)
        p_cluster(i) = mean(null_max_pos >= cluster_mass_obs(i));
    else
        p_cluster(i) = mean(null_min_neg <= cluster_mass_obs(i));
    end
end

% Build significant masks
pos_sig = false(T, F);
neg_sig = false(T, F);
for i = 1:n_clusters
    % Step 11: keep only clusters with p < ALPHA
    if p_cluster(i) < ALPHA
        if is_pos_cluster_obs(i)
            pos_sig(clusters_obs{i}) = true;
        else
            neg_sig(clusters_obs{i}) = true;
        end
    end
end

% -------------------- REPORTING --------------------
pos_cc_sig = bwconncomp(pos_sig, CONN);
neg_cc_sig = bwconncomp(neg_sig, CONN);

fprintf('Group-level surrogate-relabeling CBP\n');
fprintf('S=%d sites, K=%d maps/site (1 actual + %d surrogates), perms=%d\n', S, K, K-1, N_PERMS);
fprintf('cluster_p=%.3f (two-sided), alpha=%.3f, conn=%d\n', CLUSTER_P, ALPHA, CONN);
fprintf('Suprathreshold clusters (observed): %d\n', n_clusters);
fprintf('Significant POS clusters: %d\n', pos_cc_sig.NumObjects);
fprintf('Significant NEG clusters: %d\n', neg_cc_sig.NumObjects);

% -------------------- PLOTTING --------------------
mean_actual = mean(maps(:,:,:,1), 3);
mean_surr_all = mean(mean(maps(:,:,:,2:end), 4), 3);
mean_effect = mean(D_obs, 3);

clims = [min([mean_actual(:); mean_surr_all(:)]), max([mean_actual(:); mean_surr_all(:)])];

figure('Position', [100 100 1600 500]);
subplot(1,3,1);
imagesc(mean_surr_all); axis tight; colorbar; caxis(clims);
title('Mean surrogate (across sites)');
xlabel('Freq'); ylabel('Time');

subplot(1,3,2);
imagesc(mean_actual); axis tight; colorbar; caxis(clims);
title('Mean actual (across sites)');
xlabel('Freq'); ylabel('Time');

subplot(1,3,3);
imagesc(mean_effect); axis tight; colorbar;
title('Mean effect D (across sites)');
xlabel('Freq'); ylabel('Time');

figure('Position', [100 650 1600 500]);
subplot(1,2,1);
imagesc(t_obs); axis tight; colorbar;
title('Observed group t-map');
xlabel('Freq'); ylabel('Time');

subplot(1,2,2);
imagesc(mean_effect); axis tight; colorbar; hold on;
plotRegionBoundaries(pos_sig, [1 0 0]);
plotRegionBoundaries(neg_sig, [0 0 1]);
title('Significant clusters over mean effect');
xlabel('Freq'); ylabel('Time');

% -------------------- helpers --------------------
function [t_map, clusters, cluster_mass, is_pos_cluster, pos_mask, neg_mask] = group_tmap_and_clusters(D, cluster_p, conn, fill_holes)
    % Input D is ONE effect map per site: D(:,:,site).
    % This function:
    % - builds a group t-map across sites (per TF bin)
    % - thresholds it at cluster_p
    % - finds connected components (clusters)
    % - computes cluster mass as sum(t) inside each cluster
    [tN, fN, sN] = size(D);
    mean_D = mean(D, 3);
    stderr_D = std(D, 0, 3) ./ sqrt(sN);
    t_map = mean_D ./ (stderr_D + eps);
    df = sN - 1;

    thr_pos = tinv(1 - cluster_p/2, df);
    thr_neg = tinv(cluster_p/2, df);

    pos_mask = t_map > thr_pos;
    neg_mask = t_map < thr_neg;
    if fill_holes
        pos_mask = imfill(pos_mask, 'holes') & (t_map > 0);
        neg_mask = imfill(neg_mask, 'holes') & (t_map < 0);
    end
    pos_mask(neg_mask) = false;
    neg_mask(pos_mask) = false;

    pos_cc = bwconncomp(pos_mask, conn);
    neg_cc = bwconncomp(neg_mask, conn);

    clusters = [pos_cc.PixelIdxList, neg_cc.PixelIdxList];
    is_pos_cluster = [true(1, pos_cc.NumObjects), false(1, neg_cc.NumObjects)];
    cluster_mass = zeros(numel(clusters), 1);
    for ii = 1:numel(clusters)
        cluster_mass(ii) = sum(t_map(clusters{ii}));
    end

function m = max_cluster_mass(t_map, pos_mask, conn)
    cc = bwconncomp(pos_mask, conn);
    if cc.NumObjects == 0
        m = 0;
        return;
    end
    stats = zeros(cc.NumObjects, 1);
    for ii = 1:cc.NumObjects
        stats(ii) = sum(t_map(cc.PixelIdxList{ii}));
    end
    m = max(stats);

function m = min_cluster_mass(t_map, neg_mask, conn)
    cc = bwconncomp(neg_mask, conn);
    if cc.NumObjects == 0
        m = 0;
        return;
    end
    stats = zeros(cc.NumObjects, 1);
    for ii = 1:cc.NumObjects
        stats(ii) = sum(t_map(cc.PixelIdxList{ii}));
    end
    m = min(stats);

function plotRegionBoundaries(matrix, color)
    [rows, cols] = size(matrix);
    if ~exist('color','var') || isempty(color)
        color = [0 0 0];
    end
    hold on;
    x = [];
    y = [];
    for i = 1:rows
        for j = 1:cols
            if matrix(i,j) == 1
                if i == 1 || matrix(i-1,j) == 0
                    x = [x, j-0.5, j+0.5, NaN];
                    y = [y, i-0.5, i-0.5, NaN];
                end
                if i == rows || matrix(i+1,j) == 0
                    x = [x, j-0.5, j+0.5, NaN];
                    y = [y, i+0.5, i+0.5, NaN];
                end
            end
        end
    end
    for j = 1:cols
        for i = 1:rows
            if matrix(i,j) == 1
                if j == 1 || matrix(i,j-1) == 0
                    x = [x, j-0.5, j-0.5, NaN];
                    y = [y, i-0.5, i+0.5, NaN];
                end
                if j == cols || matrix(i,j+1) == 0
                    x = [x, j+0.5, j+0.5, NaN];
                    y = [y, i-0.5, i+0.5, NaN];
                end
            end
        end
    end
    plot(x, y, 'Color', color, 'LineWidth', 2);


