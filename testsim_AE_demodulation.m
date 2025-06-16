% --- Simulation of Extracting a Small, High-Frequency Modulated Signal ---
% --- Riding on Top of a Large, Low-Frequency Target Signal ---
% Date: 2025-05-13 (Updated to show unscaled AM signal)
% Purpose: Model a scenario where a small, high-frequency signal (representing
%          the AE component, which is the V1 activity modulated by US)
%          is added to a large, ongoing low-frequency V1 signal and other interferers.
%          The goal is to extract the information from the small AE component.

clear; clc; close all;

% --- Simulation Parameters ---
Fs = 10000;                 % Sampling frequency (Hz)
T = 2;                      % Duration of signal (seconds)
t = 0:1/Fs:T-1/Fs;          % Time vector

% Frequencies of the slow waves (Hz)
f_interfere_waves = [20, 20, 22, 25.5, 30, 35, 35, 40, 50]; % Interfering slow waves

f_V1_target_LF = 25;         % Frequency of the large, low-frequency V1 target signal (Hz)
f_carrier_US = 1000;         % High-frequency ultrasound carrier (Hz)

% Amplitudes and Phases
rng(1); % For reproducibility
amps_interfere = rand(1, length(f_interfere_waves)) * 0.5 + 0.5;
phases_interfere = rand(1, length(f_interfere_waves)) * 2 * pi;

amp_V1_target_LF = 5.0;     % Amplitude of the large, low-frequency V1 signal
phase_V1_target_LF = pi/3;

amp_carrier_for_AE = 1.0;   % Amplitude of the US carrier for AE component generation
phase_carrier_US = 0;

modulation_index_AE = 0.7;  % Modulation index for generating the AE component
ae_signal_strength_factor = 0.05; % Makes the AE component much smaller than the original V1 LF signal

% --- Generate Signals ---

% 1. Interfering Slow Waves
s_interfere = zeros(size(t));
for i = 1:length(f_interfere_waves)
    s_interfere = s_interfere + amps_interfere(i) * sin(2*pi*f_interfere_waves(i)*t + phases_interfere(i));
end

% 2. Large, Low-Frequency V1 Target Signal (directly measurable part) - This is the "message"
s_V1_target_LF = amp_V1_target_LF * sin(2*pi*f_V1_target_LF*t + phase_V1_target_LF);

% 3. Generate the "Acoustoelectric Component"
%    a) V1 LF signal modulated by US carrier (unscaled)
normalized_V1_LF_for_AE = s_V1_target_LF / amp_V1_target_LF; % Normalized to +/-1
s_ae_component_unscaled = amp_carrier_for_AE * (1 + modulation_index_AE * normalized_V1_LF_for_AE) .* cos(2*pi*f_carrier_US*t + phase_carrier_US);

%    b) Scaled (small) AE component that gets added to the mix
s_ae_component = s_ae_component_unscaled * ae_signal_strength_factor;

% --- Create the Mixed Signal ---
% s_mixed = other brain noise + LARGE V1 signal (LF) + SMALL AE component (HF, modulated V1 info)
s_mixed = s_interfere + s_V1_target_LF + s_ae_component;

% --- Plotting Details ---
xlim_time_detail = [0, 0.2]; % Show 200ms for time domain detail
xlim_time_full = [0, T];     % Show full duration

% --- Figure 1: Input Signal Components ---
figure('Name', 'Figure 1: Input Signal Components & Modulation Stages', 'Position', [50, 100, 1200, 1000]); % Made taller for 4x2

% Row 1: Original Large Low-Frequency V1 Target Signal (The "Message")
subplot(4,2,1);
plot(t, s_V1_target_LF);
title(['1a. Large LF V1 Target (', num2str(f_V1_target_LF), ' Hz) - Message']);
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(4,2,2);
plot_spectrum_local(s_V1_target_LF, Fs, ['1b. Spectrum of Large LF V1 Target (', num2str(f_V1_target_LF), ' Hz)']);
xlim([0 100]); grid on;

% Row 2: V1 Signal AFTER Modulation by US Carrier (Unscaled AM Signal)
subplot(4,2,3);
plot(t, s_ae_component_unscaled);
title('2a. V1 Signal Modulating US Carrier (Unscaled s\_ae\_unscaled)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(4,2,4);
plot_spectrum_local(s_ae_component_unscaled, Fs, '2b. Spectrum of Unscaled Modulated V1 Signal');
xlim([f_carrier_US - 4*f_V1_target_LF, f_carrier_US + 4*f_V1_target_LF]); grid on;

% Row 3: Small Acoustoelectric (AE) Component (Scaled AM Signal)
subplot(4,2,5);
plot(t, s_ae_component);
title('3a. Small AE Component (Scaled Modulated V1 - s\_ae)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(4,2,6);
plot_spectrum_local(s_ae_component, Fs, '3b. Spectrum of Small AE Component');
xlim([f_carrier_US - 4*f_V1_target_LF, f_carrier_US + 4*f_V1_target_LF]); grid on;

% Row 4: Interfering Signals
subplot(4,2,7);
plot(t, s_interfere);
title('4a. Sum of Interfering Slow Waves (s\_interfere)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(4,2,8);
plot_spectrum_local(s_interfere, Fs, '4b. Spectrum of Interfering Slow Waves');
xlim([0 100]); grid on;

sgtitle('Figure 1: Input Signal Components & Modulation Stages', 'FontSize', 14, 'FontWeight', 'bold');


% --- Figure 2: Mixed Signal & Initial Filtering ---
figure('Name', 'Figure 2: Mixed Signal & Initial Filtering', 'Position', [120, 200, 1200, 700]);

subplot(2,2,1);
plot(t, s_mixed);
title('Mixed Signal (Interferers + Large LF V1 + Small AE Comp.)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(2,2,2);
plot_spectrum_local(s_mixed, Fs, 'Spectrum of Mixed Signal');
xlim([0 f_carrier_US*1.5]); grid on;

filter_order_bp = 6;
bandpass_low_cutoff = f_carrier_US - 3*f_V1_target_LF;
bandpass_high_cutoff = f_carrier_US + 3*f_V1_target_LF;
[b_bp, a_bp] = butter(filter_order_bp, [bandpass_low_cutoff bandpass_high_cutoff]/(Fs/2), 'bandpass');
s_bandpassed = filtfilt(b_bp, a_bp, s_mixed);

subplot(2,2,3);
plot(t, s_bandpassed);
title('Band-Passed Signal (Isolating AE Component)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(2,2,4);
plot_spectrum_local(s_bandpassed, Fs, 'Spectrum of Band-Passed Signal');
xlim([f_carrier_US - 4*f_V1_target_LF, f_carrier_US + 4*f_V1_target_LF]); grid on;
sgtitle('Figure 2: Mixed Signal & Band-Pass Filtering', 'FontSize', 14, 'FontWeight', 'bold');


% --- Figure 3: Demodulation & Recovery ---
figure('Name', 'Figure 3: Demodulation & Recovery of V1 info from AE Comp.', 'Position', [190, 300, 1200, 700]);

s_local_oscillator = cos(2*pi*f_carrier_US*t + phase_carrier_US);
s_multiplied = s_bandpassed .* s_local_oscillator;

subplot(2,2,1);
plot(t, s_multiplied);
title('Signal After Multiplication by Local Oscillator');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);

subplot(2,2,2);
plot_spectrum_local(s_multiplied, Fs, 'Spectrum After Multiplication');
xlim([0 f_carrier_US*2.2]); grid on;

filter_order_lp = 6;
lowpass_cutoff = 2 * f_V1_target_LF;
[b_lp, a_lp] = butter(filter_order_lp, lowpass_cutoff/(Fs/2), 'low');
s_recovered_from_AE_raw = filtfilt(b_lp, a_lp, s_multiplied);

subplot(2,2,3);
plot(t, s_recovered_from_AE_raw);
title('Recovered LF V1 Info (from AE Comp., Raw)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_full);

subplot(2,2,4);
plot_spectrum_local(s_recovered_from_AE_raw, Fs, 'Spectrum of Recovered LF V1 Info (from AE)');
xlim([0 100]); grid on;
sgtitle('Figure 3: Demodulation Product & Low-Pass Filtering', 'FontSize', 14, 'FontWeight', 'bold');


% --- Figure 4: Final Comparison: Original V1 LF vs. Recovered V1 LF from AE Component ---
figure('Name', 'Figure 4: Final Comparison', 'Position', [260, 400, 1000, 800]);

s_recovered_from_AE_ac = s_recovered_from_AE_raw - mean(s_recovered_from_AE_raw);
s_V1_target_LF_ac = s_V1_target_LF - mean(s_V1_target_LF);

scaling_factor_final = (0.5 * amp_carrier_for_AE * modulation_index_AE * ae_signal_strength_factor) / amp_V1_target_LF;
s_recovered_from_AE_scaled = s_recovered_from_AE_ac / scaling_factor_final;

subplot(2,2,1);
plot(t, s_V1_target_LF_ac);
title(['Original Large LF V1 Signal (', num2str(f_V1_target_LF), ' Hz, AC)']);
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_full);
ylim_val = amp_V1_target_LF * 1.1;
if isempty(ylim_val) || ylim_val == 0; ylim_val = 1; end
ylim([-ylim_val, ylim_val]);

subplot(2,2,2);
plot_spectrum_local(s_V1_target_LF_ac, Fs, ['Spectrum of Original LF V1 (', num2str(f_V1_target_LF), ' Hz)']);
xlim([0 100]); grid on;

subplot(2,2,3);
plot(t, s_recovered_from_AE_scaled);
title(['Recovered LF V1 Info (from AE, Scaled AC)']);
xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_full);
ylim([-ylim_val, ylim_val]);

subplot(2,2,4);
plot_spectrum_local(s_recovered_from_AE_scaled, Fs, ['Spectrum of Recovered LF V1 (from AE)']);
xlim([0 100]); grid on;

sgtitle('Figure 4: Final Comparison - Original LF V1 vs. Info Recovered from Small AE Component', 'FontSize', 14, 'FontWeight', 'bold');


% --- Local Function Definition (Place at the VERY END of your .m file) ---
function plot_spectrum_local(signal, Fs_in, title_text)
    L = length(signal);
    if L == 0
        plot(0,0); title([title_text, ' (Empty Signal)']);
        xlabel('Frequency (Hz)'); ylabel('Amplitude Spectrum |X(f)|'); grid on; return;
    end
    Y = fft(signal);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f_axis = Fs_in*(0:(floor(L/2)))/L;
    plot(f_axis, P1);
    title(title_text);
    xlabel('Frequency (Hz)'); ylabel('Amplitude Spectrum |X(f)|'); grid on;
end


% % --- Simulation of Modulated Signal Extraction ---
% % Date: 2025-05-13
% % Purpose: Demonstrate extraction of a specific low-frequency signal
% %          amplitude-modulated by a high-frequency carrier, from a
% %          mixture of other low-frequency signals.
% 
% clear; clc; close all;
% 
% % --- Simulation Parameters ---
% Fs = 10000;                 % Sampling frequency (Hz)
% T = 2;                      % Duration of signal (seconds)
% t = 0:1/Fs:T-1/Fs;          % Time vector
% 
% % Frequencies of the slow waves (Hz)
% f_interfere_waves = [20, 20, 22, 25, 30, 35, 35, 40, 50]; % Interfering slow waves
% % Note: One of the 25 Hz signals in f_interfere_waves acts as an unmodulated interferer
% % at the same frequency as our target.
% 
% f_target = 25;              % The specific 25 Hz frequency we want to modulate and extract
% f_carrier = 1000;           % High-frequency carrier (Hz)
% 
% % Amplitudes and Phases
% rng(0); % For reproducibility
% amps_interfere = rand(1, length(f_interfere_waves)) * 0.5 + 0.5; % Amplitudes between 0.5 and 1
% phases_interfere = rand(1, length(f_interfere_waves)) * 2 * pi;
% 
% amp_target = 0.8;           % Amplitude of our target 25 Hz signal
% phase_target = pi/4;        % Phase of our target 25 Hz signal
% 
% amp_carrier = 0.1;          % Amplitude of the carrier
% phase_carrier = 0;          % Phase of the carrier (using cosine for carrier)
% 
% modulation_index = 0.1;     % Modulation index for AM (<=1 recommended for no distortion with envelope)
% 
% % --- Generate Signals ---
% 
% % 1. Interfering Slow Waves
% s_interfere = zeros(size(t));
% for i = 1:length(f_interfere_waves)
%     s_interfere = s_interfere + amps_interfere(i) * sin(2*pi*f_interfere_waves(i)*t + phases_interfere(i));
% end
% 
% % 2. Target 25 Hz Slow Wave (the one to be modulated)
% s_target_25Hz_original = amp_target * sin(2*pi*f_target*t + phase_target);
% 
% % 3. AM Modulated Signal
% % s_am(t) = Ac * (1 + m * message(t)/Amp_message) * carrier_wave(t)
% % Normalizing message to +/- 1 before applying modulation_index
% normalized_message = s_target_25Hz_original / amp_target;
% s_am = amp_carrier * (1 + modulation_index * normalized_message) .* cos(2*pi*f_carrier*t + phase_carrier);
% 
% % 4. Create the Mixed Signal
% s_mixed = s_interfere + s_am;
% 
% % --- Plotting Details ---
% xlim_time_detail = [0, 0.2]; % Show 200ms for time domain detail of waveforms
% xlim_time_full = [0, T];     % Show full duration for final comparison
% 
% % --- Figure 1: Input Signal Components ---
% figure('Name', 'Figure 1: Input Signal Components', 'Position', [50, 300, 1200, 900]);
% 
% % Row 1: Original Target Signal
% subplot(3,2,1);
% plot(t, s_target_25Hz_original);
% title(['Original Target Signal (', num2str(f_target), ' Hz)']);
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(3,2,2);
% plot_spectrum_local(s_target_25Hz_original, Fs, ['Spectrum of Original Target (', num2str(f_target), ' Hz)']);
% xlim([0 100]); grid on;
% 
% % Row 2: Interfering Signals
% subplot(3,2,3);
% plot(t, s_interfere);
% title('Sum of Interfering Slow Waves (s\_interfere)');
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(3,2,4);
% plot_spectrum_local(s_interfere, Fs, 'Spectrum of Interfering Slow Waves');
% xlim([0 100]); grid on;
% 
% % Row 3: AM Modulated Signal (s_am)
% subplot(3,2,5);
% plot(t, s_am);
% title('AM Modulated Target Signal (s\_am)');
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(3,2,6);
% plot_spectrum_local(s_am, Fs, 'Spectrum of AM Modulated Signal (s\_am)');
% xlim([f_carrier - 4*f_target, f_carrier + 4*f_target]); grid on; % Zoom around carrier
% sgtitle('Figure 1: Input Signal Components Breakdown', 'FontSize', 14, 'FontWeight', 'bold');
% 
% 
% % --- Figure 2: Mixed Signal & Initial Filtering ---
% figure('Name', 'Figure 2: Mixed Signal & Initial Filtering', 'Position', [100, 200, 1200, 700]);
% 
% % Plot 1: Mixed signal (Time and Spectrum)
% subplot(2,2,1);
% plot(t, s_mixed);
% title('Mixed Signal (s\_interfere + s\_am)');
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(2,2,2);
% plot_spectrum_local(s_mixed, Fs, 'Spectrum of Mixed Signal');
% xlim([0 f_carrier*1.5]); grid on;
% 
% % Step 1: Band-Pass Filter around the carrier frequency
% filter_order_bp = 6;
% bandpass_low_cutoff = f_carrier - 3*f_target;
% bandpass_high_cutoff = f_carrier + 3*f_target;
% [b_bp, a_bp] = butter(filter_order_bp, [bandpass_low_cutoff bandpass_high_cutoff]/(Fs/2), 'bandpass');
% s_bandpassed = filtfilt(b_bp, a_bp, s_mixed);
% 
% % Plot 2: Band-passed signal (Time and Spectrum)
% subplot(2,2,3);
% plot(t, s_bandpassed);
% title('Band-Passed Signal (Around Carrier)');
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(2,2,4);
% plot_spectrum_local(s_bandpassed, Fs, 'Spectrum of Band-Passed Signal');
% xlim([f_carrier - 4*f_target, f_carrier + 4*f_target]); grid on;
% sgtitle('Figure 2: Mixed Signal & Band-Pass Filtering', 'FontSize', 14, 'FontWeight', 'bold');
% 
% 
% % --- Figure 3: Demodulation & Recovery ---
% figure('Name', 'Figure 3: Demodulation & Recovery', 'Position', [150, 100, 1200, 700]);
% 
% % Step 2: Coherent Demodulation
% s_local_oscillator = cos(2*pi*f_carrier*t + phase_carrier);
% s_multiplied = s_bandpassed .* s_local_oscillator;
% 
% % Plot 1: Multiplied signal (Time and Spectrum)
% subplot(2,2,1);
% plot(t, s_multiplied);
% title('Signal After Multiplication by Local Oscillator');
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(2,2,2);
% plot_spectrum_local(s_multiplied, Fs, 'Spectrum After Multiplication');
% xlim([0 f_carrier*2.2]); grid on;
% 
% % Step 3: Low-Pass Filter to recover the message
% filter_order_lp = 6;
% lowpass_cutoff = 2 * f_target;
% [b_lp, a_lp] = butter(filter_order_lp, lowpass_cutoff/(Fs/2), 'low');
% s_recovered_raw = filtfilt(b_lp, a_lp, s_multiplied); % Raw recovered (may have DC)
% 
% % Plot 2: Low-pass filtered (recovered) signal (Time and Spectrum)
% subplot(2,2,3);
% plot(t, s_recovered_raw);
% title('Low-Pass Filtered Signal (s\_recovered\_raw)');
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_detail);
% 
% subplot(2,2,4);
% plot_spectrum_local(s_recovered_raw, Fs, 'Spectrum of Low-Pass Filtered Signal');
% xlim([0 100]); grid on;
% sgtitle('Figure 3: Demodulation Product & Low-Pass Filtering', 'FontSize', 14, 'FontWeight', 'bold');
% 
% 
% % --- Figure 4: Final Comparison: Original vs Recovered Target Signal ---
% figure('Name', 'Figure 4: Final Comparison', 'Position', [200, 0, 1000, 800]);
% 
% % Remove DC and scale for comparison
% s_recovered_ac = s_recovered_raw - mean(s_recovered_raw);
% s_target_25Hz_original_ac = s_target_25Hz_original - mean(s_target_25Hz_original);
% 
% % Approximate scaling factor based on AM demodulation
% % For s_am = Ac * (1 + m * norm_msg) * cos(wc*t), demodulated message part is approx 0.5 * Ac * m * norm_msg
% % Here Ac (effective carrier amplitude in s_am after (1+...) term) is amp_carrier.
% % So recovered norm_msg part is approx 0.5 * amp_carrier * modulation_index * (original_target_amplitude/amp_target)
% % To scale s_recovered_ac back to original_target_amplitude:
% scaling_factor_for_norm_msg = (amp_carrier / 2) * modulation_index;
% s_recovered_scaled = s_recovered_ac / scaling_factor_for_norm_msg * amp_target;
% 
% 
% subplot(2,2,1);
% plot(t, s_target_25Hz_original_ac);
% title(['Original Target (', num2str(f_target), ' Hz, AC Coupled)']);
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_full);
% ylim_val = max(abs(s_target_25Hz_original_ac)) * 1.1;
% if isempty(ylim_val) || ylim_val == 0; ylim_val = 1; end % Handle empty or zero case
% ylim([-ylim_val, ylim_val]);
% 
% subplot(2,2,2);
% plot_spectrum_local(s_target_25Hz_original_ac, Fs, ['Spectrum of Original Target (', num2str(f_target), ' Hz)']);
% xlim([0 100]); grid on;
% 
% subplot(2,2,3);
% plot(t, s_recovered_scaled);
% title(['Recovered Target (', num2str(f_target), ' Hz, Scaled AC)']);
% xlabel('Time (s)'); ylabel('Amplitude'); grid on; xlim(xlim_time_full);
% ylim([-ylim_val, ylim_val]);
% 
% subplot(2,2,4);
% plot_spectrum_local(s_recovered_scaled, Fs, ['Spectrum of Recovered Target (', num2str(f_target), ' Hz)']);
% xlim([0 100]); grid on;
% 
% sgtitle('Figure 4: Final Comparison - Original vs. Recovered Target Signal', 'FontSize', 14, 'FontWeight', 'bold');
% 
% 
% % --- Local Function Definition (Place at the VERY END of your .m file) ---
% function plot_spectrum_local(signal, Fs_in, title_text)
%     L = length(signal);
%     if L == 0 % Handle empty signal case
%         plot(0,0); % Plot a dummy point
%         title([title_text, ' (Empty Signal)']);
%         xlabel('Frequency (Hz)');
%         ylabel('Amplitude Spectrum |X(f)|');
%         return;
%     end
%     Y = fft(signal);
%     P2 = abs(Y/L); % Two-sided spectrum
%     P1 = P2(1:floor(L/2)+1); % Single-sided spectrum (use floor for robustness)
%     P1(2:end-1) = 2*P1(2:end-1); % Double the amplitude (except DC and Nyquist)
%     
%     f_axis = Fs_in*(0:(floor(L/2)))/L;
%     
%     plot(f_axis, P1);
%     title(title_text);
%     xlabel('Frequency (Hz)');
%     ylabel('Amplitude Spectrum |X(f)|');
%     % xlim is set outside this function for flexibility
% end