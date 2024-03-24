%% Define system parameters
Fc = 2.452e9;% 3.0e9; % Carrier frequency: 2.452 GHz | 3.0GHz
Fs = 1e6; % Sample rate: 1 MHz
T = 1; % Duration in seconds
N = T * Fs; % Total number of samples

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


%% Frequency range
startFreq = 2.052e9; % Start frequency: 2.052 GHz
endFreq = 2.852e9; % End frequency: 2.852 GHz
stepFreq = 0.2e9; % Frequency step

windowLength = 128; % Shorter for better time resolution
overlap = windowLength - 128; % High overlap for smoothness

%% Calculate the number of iterations and prepare the figure
numIterations = length(startFreq:stepFreq:endFreq);
figure;

%% Loop through the frequency range
for FreqIndex = 1:numIterations
    FreqStart = startFreq + (FreqIndex - 1) * stepFreq;

    % Generate a chirp signal
    chrp = dsp.Chirp;
    chrp.SweepDirection = 'Unidirectional';
    chrp.InitialFrequency = FreqStart;
    chrp.TargetFrequency = FreqStart + 0.2e9;
    chrp.TargetTime = 1;
    chrp.SweepTime = 1;
    chrp.SamplesPerFrame = 1000;
    chrp.SampleRate = Fs;
    tx_waveform = hilbert(chrp());

    % Transmit and receive the signal, performing STFT
    transmitRepeat(tx, tx_waveform); % Transmit continuously in a loop

    % Process each received signal segment
    rxSignal = zeros(N, 1);
    for i = 1:T % Loop for designated seconds
        [tempSignal, ~] = rx(); % Receive one second of data
        rxSignal = rxSignal + tempSignal; % Accumulate received signal
    end

    % Stop transmission
    release(tx);

    % Perform STFT on the accumulated signal
    [S, F, T, P] = spectrogram(rxSignal, windowLength, overlap, 256, Fs, 'yaxis');

    % Plot the STFT for the current frequency step
    subplot(numIterations, 1, FreqIndex);
    surf(T, F/1e6, 10*log10(abs(P)), 'EdgeColor', 'none');
    axis xy; axis tight; colormap(jet); view(0, 90);
    xlabel('Time (s)');
    ylabel('Frequency (MHz)');
    title(sprintf('STFT Magnitude (dB) - Freq %.2f GHz', FreqStart / 1e9));
end

% Save the data if necessary
% save('spectrogramData.mat', 'spectrogramData');
