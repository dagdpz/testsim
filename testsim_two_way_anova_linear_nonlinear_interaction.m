% function testsim_two_way_anova_linear_nonlinear_interaction

% Set the random seed for reproducibility
rng(42);

% Define the levels of factors a and b
levels_a = 3; % 3 levels of factor a
levels_b = 5; % 5 levels of factor b
n_repeats = 10; % Number of replicates for each combination of a and b

% Simulate the data
a = repelem(1:levels_a, levels_b * n_repeats)';  % Factor a
b = repmat(repelem(1:levels_b, n_repeats), 1, levels_a)';  % Factor b

% Define the linear combination of factors a and b
% For example, y = 2*a + 3*b + interaction + noise
interaction = 0 * (a .* b); % Interaction term
noise = randn(size(a)); % Normally distributed random noise
y = 2*a + 3*b + interaction + noise; % Response

% Create a table for the ANOVA
data = table(a, b, y);

% Perform two-way ANOVA with interaction
anova_result = anovan(data.y, {data.a, data.b}, 'model', 2, 'varnames', {'Factor a', 'Factor b'});

% Display the ANOVA table
disp('ANOVA Results:');
disp(anova_result);

% If you want to visualize the data:
figure;
gscatter(a, y, b);
xlabel('Factor A');
ylabel('Response (y)');
title('Scatter plot of response vs Factor A, colored by Factor B');
legend('show');