function [resultant_r, resultant_theta] = testsim_vector_average(thetas)
% thetas = 2 * pi * rand(1, 100);
% testsim_vector_sum(thetas)

% Number of vectors
N = length(thetas);

% Convert each unit vector from polar to Cartesian
x = cos(thetas);
y = sin(thetas);

% Sum up all the x's and y's, divide by N
resultant_x = sum(x)/N;
resultant_y = sum(y)/N;

% Convert the resultant vector from Cartesian to polar
resultant_r = sqrt(resultant_x^2 + resultant_y^2);
resultant_theta = atan2(resultant_y, resultant_x);

% use circ_stats
[mu, ul, ll] = circ_mean(thetas);
r = circ_r(thetas);

% Plotting in polar coordinates
figure;
subplot(1,2,1);
circ_plot(thetas,'hist',[],20,true,true,'linewidth',2,'color','r')

subplot(1,2,2);
% Plot unit vectors
compass(x,y, '-b');
hold on;

% Plot resultant vector
compass(resultant_x, resultant_y, '-r'); % Plot resultant vector in red