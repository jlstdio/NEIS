%% Define system parameters
Fc = 3.0e9; % Carrier frequency: 2.452 GHz | 3.0GHz
Fs = 1e6; % Sample rate: 1 MHz
T = 2; % Duration in seconds
Amplitude = 2;

%% bring in data
data = load('water_signal_3Ghz.mat');
spectrogramData = data.spectrogramData;

%% data processing
windowLength = 128; % Shorter for better time resolution
overlap = windowLength - 128; % High overlap for smoothness

% Perform STFT
[S,F,T,P] = spectrogram(spectrogramData, windowLength, overlap, 256, Fs, 'yaxis');


% Calculate the transmitted power density
tx_power_density = (Amplitude^2) / 2; % Assuming a resistive load of 1 ohm

% Calculate the received power density over time
rx_power_density_time = 10*log10(abs(P)); % mW to dBm

% Calculate and plot the power density difference over time
power_density_diff_time = tx_power_density - rx_power_density_time;
avg_power_density_diff = mean(power_density_diff_time, 2); % Average across time

% Plot the power density difference over time
%figure;
%surf(T, F/1e6, power_density_diff_time, 'EdgeColor', 'none');
%axis xy; axis tight; colormap(jet); view(0, 90);
%xlabel('Time (s)');
%ylabel('Frequency (MHz)');
%zlabel('Power Density Difference (dB)');
%title('Power Density Difference between Transmitter and Receiver over Time');

% Plot the averaged power density difference
%figure;
%plot(F/1e6, avg_power_density_diff, 'LineWidth', 2);
%xlabel('Frequency (MHz)');
%ylabel('Average Power Density Difference (dB)');
%title('Average Power Density Difference between Transmitter and Receiver by Frequency');

% Plot the STFT
%figure;
%surf(T, F/1e6, 10*log10(abs(P)), 'EdgeColor', 'none');
%axis xy; axis tight; colormap(jet); view(0, 90);
%xlabel('Time (s)');
%ylabel('Frequency (MHz)');
%title('STFT Magnitude (dB)');

%% Calculate Effective Permittivity

% Given variables
pi = 3.141592653589793;
%avg_rx_power_density_time = mean(rx_power_density_time, 2);
PwrAbs = mean(abs(P) * 1e3, 2);
%PwrAbs = trapz(F, avg_rx_power_density_time, 1); % for each time slice, if F is a column vector
bandwidth = max(F) - min(F); % Calculate bandwidth from frequency array F
PwrGen = 10^((tx_power_density-30)/10);
PwrGen = tx_power_density * bandwidth; % Total transmitted power in watts
V = 0.25; % volume of the food
V = V * ones(size(PwrAbs));
A = 200; % average surface area
A = A * ones(size(PwrAbs));

if isscalar(PwrGen)
    PwrGen = PwrGen * ones(size(PwrAbs));
end

% Calculate E for each frequency bin over time
E = (PwrAbs .* A) ./ (PwrGen * 4 * pi .* F .* V);

% Display the result
disp(['The value of E is ', mat2str(E)]);

figure;
plot(F, E);
xlabel('Frequencies'); % Or 'Frequency (Hz)' if plotting against F
ylabel('E value');
title('E over Frequency');