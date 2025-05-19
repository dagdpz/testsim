% testsim_rma_regression

% When neither variable is strictly dependent on the other, and you want to assess the linear relationship and slope between two variables, 
% reduced major axis (RMA) regression or Deming regression is appropriate. 
% These methods account for measurement variability in both variables, unlike ordinary least squares (OLS) regression, which assumes all error is in the dependent variable.


% Example data
x = rand(100, 1); % Firing rates in condition 1
y = 3 * x + randn(100, 1) * 0.5; % Firing rates in condition 2

% Calculate Pearson correlation coefficient
r = corr(x, y);

% Calculate RMA regression slope and intercept
slope_rma = sign(r) * std(y) / std(x);
intercept_rma = mean(y) - slope_rma * mean(x);

% Generate fitted values
y_fit = slope_rma * x + intercept_rma;

% Plot scatter and regression line
figure;
scatter(x, y, 'b', 'filled'); hold on;
plot(x, y_fit, 'r-', 'LineWidth', 2);
xlabel('Condition 1 (Firing Rate)');
ylabel('Condition 2 (Firing Rate)');
title(['RMA Regression: Slope = ', num2str(slope_rma), ' Intercept = ', num2str(intercept_rma), ' r = ', num2str(r)]);
legend('Data', 'RMA Fit', 'Location', 'Best');
grid on;

% Other options:
if 1
s=[2,2];
[b_rma,bint,l,ang,r] = rmaregress(x,y,s)

[b sigma2_x x_est y_est stats] = deming(x,y);
end