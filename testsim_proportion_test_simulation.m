function testsim_proportion_test_simulation

    alpha = 0.05;

    % Parameters for the simulation
    N1 = 30; % Number of sessions in group 1
    N2 = 30; % Number of sessions in group 2
    trials_per_session = 400; % Total trials per session
    p_visible_group1 = 0.65; % Coordination rate for visible in group 1
    p_not_visible_group1 = 0.5; % Coordination rate for not visible in group 1
    p_visible_group2 = 0.3; % Coordination rate for visible in group 2
    p_not_visible_group2 = 0.6; % Coordination rate for not visible in group 2

 % Simulate sessions
    [group1_zscores, group1_pvalues] = simulate_sessions(N1, trials_per_session, p_visible_group1, p_not_visible_group1);
    [group2_zscores, group2_pvalues] = simulate_sessions(N2, trials_per_session, p_visible_group2, p_not_visible_group2);

    % Combine data for plotting
    zscores = [group1_zscores; group2_zscores];
    p_values = [group1_pvalues; group2_pvalues];
    groups = [ones(N1, 1); 2 * ones(N2, 1)];
    % significance = abs(zscores) > 1.96; % Significant sessions
    significance = p_values < alpha; % Significant sessions 
    
    % Plotting
    figure;
    hold on;
       

    % plot all 
    daboxplot(zscores,'groups',groups,...
    'fill',0,'whiskers',1,'scatter',2,'scatteralpha',0.5,'jitter',0,...
    'outliers',0,'scattersize',40,'flipcolors',1,'boxspacing',1.2); 

    % plot not significant
    scatter(ones(size(group1_zscores(group1_pvalues>=alpha))), group1_zscores(group1_pvalues>=alpha), 20, 'o', ...
        'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);
    scatter(2*ones(size(group2_zscores(group2_pvalues>=alpha))), group2_zscores(group2_pvalues>=alpha), 20, 'o', ...
        'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);


    % Labels and legend
    xlabel('Groups');
    ylabel('Z-scores');
    title('Session-level Z-scores for Visibility Effect on Coordination');

end

function [zscores, pvalues] = simulate_sessions(N, trials, p_visible, p_not_visible)
    % Simulate sessions and compute z-scores and p-values
    zscores = zeros(N, 1);
    pvalues = zeros(N, 1);
    for i = 1:N
        % Simulate visible and not visible trials
        visible_trials = trials * 0.75; % 75% of trials are visible
        not_visible_trials = trials * 0.25; % 25% of trials are not visible
        coord_visible = binornd(visible_trials, p_visible);
        coord_not_visible = binornd(not_visible_trials, p_not_visible);

        % Two-proportion z-test
        [zscores(i), pvalues(i)] = two_proportion_ztest(coord_visible, visible_trials, ...
                                                        coord_not_visible, not_visible_trials);
    end
end

function [z, p] = two_proportion_ztest(c1, n1, c2, n2)
    % Two-proportion z-test with p-value
    p1 = c1 / n1;
    p2 = c2 / n2;
    p_pooled = (c1 + c2) / (n1 + n2);
    se = sqrt(p_pooled * (1 - p_pooled) * (1/n1 + 1/n2));
    z = (p1 - p2) / se;

    % Compute two-tailed p-value
    p = 2 * (1 - normcdf(abs(z))); % normcdf is the standard normal CDF
end