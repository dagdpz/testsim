function testsim_fit_normal_dist
% Step 1: Generate simulated normally-distributed data
mu = 5; % mean of the distribution
sigma = 1; % standard deviation of the distribution
n = 1000; % number of data points
data = mu + sigma * randn(n, 1); % generate data

% Step 2: Fit a Gaussian distribution to the data
dist = fitdist(data, 'Normal');

% Step 3: Plot the histogram of the data
histogram(data, 'Normalization', 'pdf');
hold on;

% Overlay the PDF of the fitted Gaussian distribution
x_values = linspace(min(data), max(data), 1000);
pdf_values = pdf(dist, x_values);
plot(x_values, pdf_values, 'LineWidth', 2);

% Display the parameters of the fitted Gaussian distribution
fprintf('Fitted Gaussian parameters:\n');
fprintf('Mean = %f\n', dist.mu);
fprintf('Standard Deviation = %f\n', dist.sigma);

% Step 4: Define an arbitrary threshold and plot it
threshold = 0.1;
y_lim = ylim;
plot([threshold threshold], y_lim, '--r', 'LineWidth', 2);

% Calculate the actual number of data points below the threshold
actual_below_threshold = sum(data < threshold);
actual_percentage = (actual_below_threshold / n) * 100;

% Calculate the theoretical percentage of elements below the threshold
theoretical_percentage = cdf(dist, threshold) * 100;

hold off;

% Display the actual and theoretical percentages
fprintf('Threshold: %f\n', threshold);
fprintf('Actual number of elements below threshold: %d\n', actual_below_threshold);
fprintf('Actual percentage of elements below threshold: %f%%\n', actual_percentage);
fprintf('Theoretical percentage of elements below threshold: %f%%\n', theoretical_percentage);
