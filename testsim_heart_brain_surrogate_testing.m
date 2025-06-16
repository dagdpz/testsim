function testsim_heart_brain_surrogate_testing
    % Parameters
    fs = 1000;           % Sampling frequency (Hz)
    duration = 300;      % Recording duration (seconds)
    t = (0:1/fs:duration-1/fs)';  % Make column vector
    n_samples = length(t);

    % Simulation parameters
    params = struct(...
        'mean_hr', 60, ...        % Mean heart rate (bpm)
        'hrv_std', 0.2, ...       % HR variability
        'mod_freq', 2, ...        % Modulation frequency for phase coupling
        'mod_amp', 1, ...         % Modulation amplitude
        'latency', 0.3, ...       % Response latency (s)
        'duration_ms', 100, ...   % Response duration (ms)
        'noise_level', 0.2);      % Noise amplitude

    % Analysis parameters
    n_surrogates = 100;
    window = (-500:500)';  % Analysis window in samples
    
    % Input validation
    validateParams(params, fs, duration);

    % Generate cardiac events
    [r_peaks, rr_intervals] = generate_r_peaks(fs, duration, params.mean_hr, params.hrv_std);

    % Generate signals - preallocate for efficiency
    signals = struct();
    signals.phase = generate_phase_modulated(t, r_peaks, fs, params) + ...
                   params.noise_level * randn(n_samples, 1);
    signals.latency = generate_latency_locked(t, r_peaks, fs, params) + ...
                     params.noise_level * randn(n_samples, 1);
    signals.null = params.noise_level * randn(n_samples, 1);

    % Compute PLV for original signals
    plv = struct();
    [plv.orig_phase, plv.phase_significance] = compute_plv(signals.phase, r_peaks, window, fs);
    [plv.orig_latency, plv.latency_significance] = compute_plv(signals.latency, r_peaks, window, fs);
    [plv.orig_null, plv.null_significance] = compute_plv(signals.null, r_peaks, window, fs);

    % Generate surrogate data and compute statistics - preallocate
    plv.surr_phase = zeros(n_surrogates, length(window));
    plv.surr_latency = zeros(n_surrogates, length(window));
    plv.surr_null = zeros(n_surrogates, length(window));

    % Parallel computation of surrogates if parallel pool available
    if isempty(gcp('nocreate'))
        for i = 1:n_surrogates
            plv.surr_phase(i,:) = compute_surrogate_plv(signals.phase, r_peaks, window, fs);
            plv.surr_latency(i,:) = compute_surrogate_plv(signals.latency, r_peaks, window, fs);
            plv.surr_null(i,:) = compute_surrogate_plv(signals.null, r_peaks, window, fs);
        end
    else
        for i = 1:n_surrogates
            plv.surr_phase(i,:) = compute_surrogate_plv(signals.phase, r_peaks, window, fs);
            plv.surr_latency(i,:) = compute_surrogate_plv(signals.latency, r_peaks, window, fs);
            plv.surr_null(i,:) = compute_surrogate_plv(signals.null, r_peaks, window, fs);
        end
    end

    % Compute statistics
    stats = compute_statistics(plv);
    
    % Visualization
    visualize_results(t, signals, r_peaks, window, fs, plv, stats);
end

function validateParams(params, fs, duration)
    assert(fs > 0 && mod(fs,1) == 0, 'Sampling frequency must be positive integer');
    assert(duration > 0, 'Duration must be positive');
    assert(params.mean_hr > 0 && params.mean_hr < 300, 'Invalid heart rate');
    assert(params.hrv_std >= 0, 'HRV std must be non-negative');
    assert(params.latency >= 0, 'Latency must be non-negative');
    assert(params.duration_ms > 0, 'Response duration must be positive');
    assert(params.noise_level >= 0, 'Noise level must be non-negative');
end

function [r_peaks, rr_intervals] = generate_r_peaks(fs, duration, mean_hr, hrv_std)
    mean_rr = 60/mean_hr;
    n_beats = ceil(duration/mean_rr * 1.2);
    
    % Generate log-normal RR intervals
    rr_intervals = exp(log(mean_rr) + hrv_std * randn(n_beats, 1));
    
    % Convert to sample indices
    r_peaks = cumsum(round(rr_intervals * fs));
    valid_peaks = r_peaks <= duration*fs;
    r_peaks = r_peaks(valid_peaks);
    rr_intervals = diff([0; r_peaks])/fs;
end

function signal = generate_phase_modulated(t, r_peaks, fs, params)
    signal = zeros(size(t));
    phase = zeros(size(t));
    
    % Vectorized phase computation
    for i = 1:length(r_peaks)-1
        idx = r_peaks(i):min(r_peaks(i+1), length(t));
        phase(idx) = linspace(0, 2*pi, length(idx));
    end
    
    signal = params.mod_amp * sin(params.mod_freq * phase);
end

function signal = generate_latency_locked(t, r_peaks, fs, params)
    % Create Gaussian pulse template
    duration_samples = round(params.duration_ms/1000 * fs);
    pulse = exp(-(0:duration_samples).^2 / (2*(duration_samples/4)^2));
    
    % Create event train using logical indexing
    event_train = zeros(size(t));
    latency_samples = round(params.latency * fs);
    event_indices = r_peaks + latency_samples;
    valid_indices = event_indices(event_indices + duration_samples <= length(event_train));
    event_train(valid_indices) = 1;
    
    % Efficient convolution
    signal = conv(event_train, pulse, 'same');
end

function [plv, significance] = compute_plv(signal, r_peaks, window, fs)
    % Preallocate
    n_peaks = length(r_peaks);
    n_samples = length(window);
    epochs = zeros(n_peaks, n_samples);
    
    % Extract valid epochs using logical indexing
    valid_peaks = (r_peaks + max(window) <= length(signal)) & ...
                 (r_peaks + min(window) > 0);
    valid_idx = find(valid_peaks);
    
    % Vectorized epoch extraction
    for i = 1:length(valid_idx)
        epochs(i,:) = signal(r_peaks(valid_idx(i)) + window);
    end
    
    % Remove unused preallocated rows
    epochs = epochs(1:length(valid_idx), :);
    
    % Efficient Hilbert transform
    analytic_signal = hilbert(epochs')';
    phases = angle(analytic_signal);
    
    % Compute PLV and significance
    plv = abs(mean(exp(1i * phases), 1));
    significance = zeros(size(plv));
    
    % Rayleigh test for uniformity
    z = length(valid_idx) * plv.^2;
    significance = exp(-z);  % p-values
end

function plv = compute_surrogate_plv(signal, r_peaks, window, fs)
    % Generate phase-randomized surrogate
    surrogate = phase_randomization(signal);
    
    % Compute PLV for surrogate
    [plv, ~] = compute_plv(surrogate, r_peaks, window, fs);
end

function signal_surr = phase_randomization(signal)
    N = length(signal);
    
    % FFT
    fft_sig = fft(signal);
    
    % Generate random phases preserving conjugate symmetry
    n_unique = floor(N/2) + 1;
    rand_phases = [0; 2*pi*rand(n_unique-2, 1); 0];  % Zero at DC and Nyquist
    
    if mod(N,2) == 0
        rand_phases = [rand_phases; -flipud(rand_phases(2:end-1))];
    else
        rand_phases = [rand_phases; -flipud(rand_phases(2:end))];
    end
    
    % Apply random phases and IFFT
    signal_surr = real(ifft(abs(fft_sig) .* exp(1i * rand_phases)));
end

function stats = compute_statistics(plv)
    stats = struct();
    
    % Compute statistics for each signal type
    fields = {'phase', 'latency', 'null'};
    for i = 1:length(fields)
        field = fields{i};
        surr_data = plv.(['surr_' field]);
        orig_data = plv.(['orig_' field]);
        
        % Compute mean and confidence intervals
        stats.([field '_mean']) = mean(surr_data, 1);
        stats.([field '_ci95']) = prctile(surr_data, [2.5 97.5], 1);
        
        % Compute z-scores
        stats.([field '_zscore']) = (orig_data - mean(surr_data)) ./ std(surr_data);
        
        % Compute p-values
        stats.([field '_pval']) = mean(max(surr_data, [], 2) > max(orig_data));
    end
end

function visualize_results(t, signals, r_peaks, window, fs, plv, stats)
    figure('Position', [100 100 1200 800]);
    
    % Time series plots
    subplot(3,2,1);
    plot_timeseries(t, signals.phase, r_peaks, fs, 'Phase-modulated Signal');
    
    subplot(3,2,2);
    plot_timeseries(t, signals.latency, r_peaks, fs, 'Latency-locked Signal');
    
    % PLV results
    subplot(3,2,3);
    plot_plv_results(window, plv.orig_phase, plv.surr_phase, fs, stats.phase_ci95, ...
                    'PLV: Phase-modulated');
    
    subplot(3,2,4);
    plot_plv_results(window, plv.orig_latency, plv.surr_latency, fs, stats.latency_ci95, ...
                    'PLV: Latency-locked');
    
    % Statistical results
    subplot(3,2,5:6);
    plot_statistics(plv, stats);
end

function plot_timeseries(t, signal, r_peaks, fs, title_str)
    % Plot first 5 seconds of data
    plot_idx = 1:min(5*fs, length(t));
    plot(t(plot_idx), signal(plot_idx));
    hold on;
    plot(r_peaks(r_peaks <= max(t(plot_idx)))/fs, ...
         zeros(sum(r_peaks <= max(t(plot_idx))),1), 'r^');
    title(title_str);
    xlabel('Time (s)');
    ylabel('Amplitude');
end

function plot_plv_results(window, orig_plv, surr_plv, fs, ci, title_str)
    plot(window/fs, orig_plv, 'b', 'LineWidth', 2);
    hold on;
    plot(window/fs, mean(surr_plv, 1), 'r--');
    fill([window/fs; flipud(window/fs)], ...
         [ci(1,:)'; flipud(ci(2,:))'], ...
         'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    title(title_str);
    xlabel('Time (s)');
    ylabel('PLV');
    legend('Original', 'Surrogate mean', '95% CI');
end

function plot_statistics(plv, stats)
    histogram(max(plv.surr_phase, [], 2), 20, 'Normalization', 'probability');
    hold on;
    plot([max(plv.orig_phase) max(plv.orig_phase)], ylim, 'r--', 'LineWidth', 2);
    title('Surrogate Statistics Distribution');
    xlabel('Max PLV');
    ylabel('Probability');
    legend(sprintf('Surrogates (p = %.3f)', stats.phase_pval), 'Original');
end