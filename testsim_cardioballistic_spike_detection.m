function testsim_cardioballistic_spike_detection

% Parameters for the simulation
n = 1000; % number of data points (heartbeats)
heart_rate_hz = 1; % heart rate in Hertz (cycles per second)
mu = 0; % mean of the Gaussian noise
sigma = 0.1; % standard deviation of the Gaussian noise

% Generate phase values from 0 to 2*pi for one cycle
phases = linspace(0, 2*pi, n);

% Define the sine waveform (amplitude) for one cycle of a heart-rate R to R peak cycle
sine_waveform = sin(phases);

% Generate Gaussian noise
noise = mu + sigma * randn(size(sine_waveform));

% Combine the sine waveform with Gaussian noise to simulate the amplitude
amplitude = sine_waveform + noise;

% Fit a Gaussian distribution to the noisy data
dist = fitdist(amplitude', 'Normal');

% Plot the noisy sine waveform (amplitude) as a function of the phase
figure;
plot(phases, amplitude, '.');
xlabel('Phase (radians)');
ylabel('Amplitude');
title('Noisy Sine Waveform Representing Heart-Rate Cycle');
