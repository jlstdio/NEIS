%% Define system parameters
Fc = 3.0e9; % Carrier frequency: 2.452 GHz | 3.0GHz
Fs = 1e6; % Sample rate: 1 MHz
T = 2; % Duration (secs)
Amplitude = 2;

spectrogramData_water = {};
spectrogramData_A = {};
spectrogramData_B = {};

%% Data list
% './data/noWater_spectrogramData_Freq 3.80 GHz.mat'
% './data/waterUnderneath_spectrogramData_Freq 3.00 GHz.mat'
% './data/water_280gm_spectrogramData_Freq 3.00 GHz.mat'
% './data/coffeeA_282gm_spectrogramData_Freq 3.80 GHz.mat'
% './data/coffeeB_283gm_spectrogramData_Mar28_2024_Freq 3.80 GHz.mat'
% './data/proteinShakeA_255gm_spectrogramData_Mar28_2024_Freq 3.00 GHz.mat'

frequencies = [3.00, 3.20, 3.40, 3.60, 3.80];
FreqArrSize = length(frequencies);

% Loop through each frequency and load the corresponding data
for i = 1:FreqArrSize
    filename = sprintf('./data/water_280gm_spectrogramData_Freq %.2f GHz.mat', frequencies(i));
    data = load(filename);  % Load the file
    spectrogramData_water{end+1} = data.rxSignal;  % Append the data to the cell array
end

% Loop through each frequency and load the corresponding data
for i = 1:FreqArrSize
    filename = sprintf('./data/water_280gm_spectrogramData_Mar30_2024_Freq %.2f GHz', frequencies(i));
    data = load(filename);  % Load the file
    spectrogramData_A{end+1} = data.rxSignal;  % Append the data to the cell array
end


% Loop through each frequency and load the corresponding data
for i = 1:FreqArrSize
    filename = sprintf('./data/noWater_spectrogramData_Freq %.2f GHz', frequencies(i));
    data = load(filename);  % Load the file
    spectrogramData_B{end+1} = data.rxSignal;  % Append the data to the cell array
end



%% data processing
windowLength = 128; % Shorter for better time resolution
overlap = windowLength - 128; % High overlap for smoothness
arraySize = 5;

% STFT

S_W = {}; F_W = {}; T_W = {}; P_W = {};
for i = 1:arraySize
    [S_W{end+1}, F_W{end+1}, T_W{end+1}, P_W{end+1}] = spectrogram(spectrogramData_water{i}, windowLength, overlap, 256, Fs, 'yaxis');
end

S_A = {}; F_A = {}; T_A = {}; P_A = {};
for i = 1:arraySize
    [S_A{end+1}, F_A{end+1}, T_A{end+1}, P_A{end+1}] = spectrogram(spectrogramData_A{i}, windowLength, overlap, 256, Fs, 'yaxis');
end

S_B = {}; F_B = {}; T_B = {}; P_B = {};
for i = 1:arraySize
    [S_B{end+1}, F_B{end+1}, T_B{end+1}, P_B{end+1}] = spectrogram(spectrogramData_B{i}, windowLength, overlap, 256, Fs, 'yaxis');
end

% Calculate the transmitted power density
tx_power_density = (Amplitude^2) / 2; % Assuming a resistive load of 1 ohm

% Calculate the received power density over time
rx_power_density_w = {};
for i = 1:arraySize
    rx_power_density_w{end+1} = 10*log10(abs(P_W{i})); % mW to dBm
end

rx_power_density_A = {};
for i = 1:arraySize
    rx_power_density_A{end+1} = 10*log10(abs(P_A{i}));
end

rx_power_density_B = {};
for i = 1:arraySize
    rx_power_density_B{end+1} = 10*log10(abs(P_B{i})); % mW to dBm
end

% Calculate the power density difference over time
power_density_diff_W = {};
for i = 1:arraySize
    power_density_diff_W{end+1} = tx_power_density - rx_power_density_w{i};
end

power_density_diff_A = {};
for i = 1:arraySize
    power_density_diff_A{end+1} = tx_power_density - rx_power_density_A{i};
end

power_density_diff_B = {};
for i = 1:arraySize
    power_density_diff_B{end+1} = tx_power_density - rx_power_density_B{i};
end

%% plotting
% Plot the power density difference over time
%figure;
%surf(T, F/1e6, power_density_diff_time, 'EdgeColor', 'none');
%axis xy; axis tight; colormap(jet); view(0, 90);
%xlabel('Time (s)');
%ylabel('Frequency (MHz)');
%zlabel('Power Density Difference (dB)');
%title('Power Density Difference between Transmitter and Receiver over Time');

time = 1000;

% Plot the averaged power density difference
figure;
numPlots = 5;
for i = 1:numPlots
    subplot(numPlots, 1, i); % Create subplot (5 rows, 1 column, i-th position)
    plot(F_W{i}/Fs, power_density_diff_W{i}(:, time), 'LineWidth', 2);
    hold on; % Hold on to the current plot
    plot(F_A{i}/Fs, power_density_diff_A{i}(:, time), 'LineWidth', 2);
    plot(F_B{i}/Fs, power_density_diff_B{i}(:, time), 'LineWidth', 2);
    hold off; % Release the plot
    xlabel('F (MHz)');
    ylabel('Avg Power Density Difference (dB)');
end
hold off; % Releases the plot

% Plot the STFT
%figure;
%surf(T, F/1e6, 10*log10(abs(P)), 'EdgeColor', 'none');
%axis xy; axis tight; colormap(jet); view(0, 90);
%xlabel('Time (s)');
%ylabel('Frequency (MHz)');
%title('STFT Magnitude (dB)');

%% Calculate Effective Permittivity
% Given variables
%pi = 3.141592653589793;
%avg_rx_power_density_time = mean(rx_power_density_time, 2);
%PwrAbs = mean(abs(P) * 1e3, 2);
%PwrAbs = trapz(F, avg_rx_power_density_time, 1); % for each time slice, if F is a column vector
%bandwidth = max(F) - min(F); % Calculate bandwidth from frequency array F
%PwrGen = 10^((tx_power_density-30)/10);
%PwrGen = tx_power_density * bandwidth; % Total transmitted power in watts
%V = 0.25; % volume of the food
%V = V * ones(size(PwrAbs));
%A = 200; % average surface area
%A = A * ones(size(PwrAbs));

%if isscalar(PwrGen)
%    PwrGen = PwrGen * ones(size(PwrAbs));
%end

% Calculate E for each frequency bin over time
%E = (PwrAbs .* A) ./ (PwrGen * 4 * pi .* F .* V);

% Display the result
%disp(['The value of E is ', mat2str(E)]);

%figure;
%plot(F, E);
%xlabel('Frequencies'); % Or 'Frequency (Hz)' if plotting against F
%ylabel('E value');
%title('E over Frequency');