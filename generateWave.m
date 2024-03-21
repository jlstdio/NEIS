%% Define system parameters
Fc = 3.0e9; % Carrier frequency: 2.452 GHz | 3.0GHz
Fs = 1e6; % Sample rate: 1 MHz
T = 2; % Duration in seconds
N = T * Fs; % Total number of samples

%% Generate a sine wave
sw = dsp.SineWave;
sw.Amplitude = 2;
sw.Frequency = Fc;
sw.ComplexOutput = true;
sw.SampleRate = Fs;
sw.SamplesPerFrame = 1000; % to meet waveform size requirements
tx_waveform = sw();

%% Setup PlutoSDR transmitter
tx = sdrtx('Pluto');
tx.CenterFrequency = Fc;
tx.BasebandSampleRate = Fs;
tx.Gain = -10; % Adjust the gain as needed

%% Setup PlutoSDR receiver
rx = sdrrx('Pluto');
rx.CenterFrequency = Fc;
rx.BasebandSampleRate = Fs;
rx.OutputDataType = 'double';
rx.SamplesPerFrame = N;
rx.GainSource = 'Manual';
rx.Gain = 30; % Adjust the gain as needed

%% Tx & Rx -> STFT
% Transmit and receive the signal, performing STFT
transmitRepeat(tx, tx_waveform); % Transmit continuously in a loop

% Prepare for STFT
spectrogramData = [];

for i = 1:T % Loop for 10 seconds
    [rxSignal, ~] = rx(); % Receive one second of data
    spectrogramData = [spectrogramData; rxSignal]; % Append received signal for STFT
end

% Stop transmission
release(tx);

windowLength = 128; % Shorter for better time resolution
overlap = windowLength - 128; % High overlap for smoothness

% Perform STFT
[S,F,T,P] = spectrogram(spectrogramData, windowLength, overlap, 256, Fs, 'yaxis');

% Plot the STFT
figure;
surf(T, F/1e6, 10*log10(abs(P)), 'EdgeColor', 'none');
axis xy; axis tight; colormap(jet); view(0, 90);
xlabel('Time (s)');
ylabel('Frequency (MHz)');
title('STFT Magnitude (dB)');

%% Save
% Save the received signal to a MAT file
save('water_signal_3Ghz.mat', 'spectrogramData');
