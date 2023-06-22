% function testsim_firing_rate_stability

% Generate time series data
N = 1000; % number of data points
t = 1:N; % time vector
change_point = 250;

noise_level = 0.3;
stepsize = 0.5;

% Time series with abrupt change
abrupt = [noise_level*randn(1, change_point) stepsize + noise_level*randn(1, N - change_point)];

% Time series with gradual change
gradual = linspace(1, stepsize, N) + noise_level*randn(1, N);

% Stable time series
stable = noise_level*randn(1, N);

% Compute ACF
[autoCorrAbrupt, lagsAbrupt] = xcorr(abrupt - mean(abrupt), 'coeff');
[autoCorrGradual, lagsGradual] = xcorr(gradual - mean(gradual), 'coeff');
[autoCorrStable, lagsStable] = xcorr(stable - mean(stable), 'coeff');

% Plot time series
figure;
subplot(2, 3, 1);
plot(t, abrupt); title('Time series with abrupt change'); hold on
ichangepoint = findchangepts(abrupt, 'MinThreshold', 5*std(abrupt));
ig_add_multiple_vertical_lines(t(ichangepoint),'Color',[1 0 0]); clear ichangepoint
ichangepoint = findchangepts(abrupt, 'Statistic', 'linear','MinThreshold', 5*std(abrupt));
ig_add_multiple_vertical_lines(t(ichangepoint),'Color',[1 0 1]); clear ichangepoint


subplot(2, 3, 2);
plot(t, gradual); title('Time series with gradual change');
ichangepoint = findchangepts(gradual, 'MinThreshold', 5*std(gradual));
ig_add_multiple_vertical_lines(t(ichangepoint),'Color',[1 0 0]); clear ichangepoint
ichangepoint = findchangepts(gradual, 'Statistic', 'linear','MinThreshold', 5*std(gradual));
ig_add_multiple_vertical_lines(t(ichangepoint),'Color',[1 0 1]); clear ichangepoint

subplot(2, 3, 3);
plot(t, stable); title('Stable time series');
ichangepoint = findchangepts(stable, 'MinThreshold', 5*std(stable));
ig_add_multiple_vertical_lines(t(ichangepoint),'Color',[1 0 0]);

% Plot ACF
subplot(2, 3, 4);
plot(lagsAbrupt, autoCorrAbrupt); title('ACF of abrupt change series');
subplot(2, 3, 5);
plot(lagsGradual, autoCorrGradual); title('ACF of gradual change series');
subplot(2, 3, 6);
plot(lagsStable, autoCorrStable); title('ACF of stable series');