%% Frequency Correction for ADALM-PLUTO Radio
% This example shows how to synchronize both the baseband sample rate and
% the center frequency of two PlutoSDRs by using the FrequencyCorrection
% property of comm.SDRRxPluto and comm.SDRTxPluto.
%
% The baseband sample rate and the center frequency of a PlutoSDR are
% physically derived from the same oscillator. Although each PlutoSDR is
% factory-calibrated to use appropriate PLL settings to digitally
% compensate for component variations of the oscillator, the compensation
% is imperfect because of quantization effects and changes in operating
% conditions (temperature in particular). Consequently, two PlutoSDRs will
% operate at slightly different baseband sample rates and center
% frequencies even if the corresponding System objects for the two
% PlutoSDRs use the same values for the BasebandSampleRate and
% CenterFrequency properties. To solve this problem, the
% FrequencyCorrection property of comm.SDRRxPluto and comm.SDRTxPluto can
% be used.
%
% The FrequencyCorrection property specifies the parts-per-million change
% to the baseband sample rate and the center frequency. The default value
% is 0, which means that the radio will use its factory-calibrated PLL
% settings. In this example, we treat one PlutoSDR, the transmitter, as a
% source with accurate baseband sample rate and center frequency. We use
% the signal received by another PlutoSDR, the receiver, to estimate the
% right value of FrequencyCorrection for the receiver System object, and
% show that when FrequencyCorrection is set appropriately, the frequency
% offset between the transmitter and the receiver will be removed almost
% completely.
%
% Refer to the <docid:plutoradio_ug#bvn89q2-14 Getting Started>
% documentation for details on configuring your host computer to work with
% the PlutoSDR.

% Copyright 2017-2022 The MathWorks, Inc.

%% Algorithm for Estimating Frequency Correction
%
% Consider a signal transmitted from one PlutoSDR to another PlutoSDR.
% Let $f_{c}$ and $f_{s}$ be the center frequency and the baseband sample
% rate of the transmitter. Let $f_{c'}$ and $f_{s'}$ be the center frequency
% and the baseband sample rate of the receiver. Assume that the oscillator
% of the transmitter has not drifted and the oscillator of the receiver
% has drifted by a factor $K$, i.e. $f_{c'} = K * f_{c}$ and
% $f_{s'} = K * f_{s}$ where $K$ is a number very close to 1.
%
% A tone at baseband frequency $f_{ref}$ in the transmitted signal will
% appear as a tone at baseband frequency $f_{received}$ in the receiver,
% where $f_{received} = {{f_{ref} + (f_{c} - K*f_c)}\over{K}}$.
% The term $(f_{c} - K*f_c)$ in the numerator is due to the mismatch in center frequencies.
% The scaling factor $K$ in the denominator is due to the mismatch in baseband sample rates.
% Hence, we can solve for $K$ with $f_{ref}$, $f_{received}$, and $f_c$. $K = {{f_c +
% f_{ref}}\over{f_c + f_{received}}}$.
%
% To remove the frequency offset between the transmitter and the receiver,
% we need to scale the baseband sample rate and the center frequency of the
% receiver by a factor of $1\over K$. Let $p$ be the parts-per-million
% change to the baseband sample rate and the center frequency of the
% receiver. Then $1 + {p\over 10^6} = {1\over K}$. Therefore
% $p = {{f_{received} - f_{ref}}\over{f_{c} + f_{ref}}} * 10^6$.
%
%% Set up the Transmitter and the Receiver
%
% We use one PlutoSDR to transmit three tones at 20, 40, and 80 kHz. The
% tone at 80 kHz is used to estimate the value for FrequencyCorrection for
% the receiver. The tones at 20 and 40 kHz are only used to help visualize
% the spectrum.

% Set up parameters and signals
sampleRate = 200e3;
centerFreq = 2.42e9;
fRef = 80e3;
s1 = exp(1j*2*pi*20e3*[0:10000-1]'/sampleRate);  % 20 kHz
s2 = exp(1j*2*pi*40e3*[0:10000-1]'/sampleRate);  % 40 kHz
s3 = exp(1j*2*pi*fRef*[0:10000-1]'/sampleRate);  % 80 kHz
s = s1 + s2 + s3;
s = 0.6*s/max(abs(s)); % Scale signal to avoid clipping in the time domain

% Set up the transmitter
% Use the default value of 0 for FrequencyCorrection, which corresponds to
% the factory-calibrated condition
tx = sdrtx('Pluto', 'RadioID', 'usb:1', 'CenterFrequency', centerFreq, ...
           'BasebandSampleRate', sampleRate, 'Gain', 0, ...
           'ShowAdvancedProperties', true);
% Use the info method to show the actual values of various hardware-related
% properties
txRadioInfo = info(tx)
% Send signals
disp('Send 3 tones at 20, 40, and 80 kHz');
transmitRepeat(tx, s);

% Set up the receiver
% Use the default value of 0 for FrequencyCorrection, which corresponds to
% the factory-calibrated condition
numSamples = 1024*1024;
rx = sdrrx('Pluto', 'RadioID', 'usb:0', 'CenterFrequency', centerFreq, ...
           'BasebandSampleRate', sampleRate, 'SamplesPerFrame', numSamples, ...
           'OutputDataType', 'double', 'ShowAdvancedProperties', true);
% Use the info method to show the actual values of various hardware-related
% properties
rxRadioInfo = info(rx)

%% Receive and Visualize Signal

disp(['Capture signal and observe the frequency offset' newline])
receivedSig = rx();

% Find the tone that corresponds to the 80 kHz transmitted tone
y = fftshift(abs(fft(receivedSig)));
[~, idx] = findpeaks(y,'MinPeakProminence',max(0.5*y));
fReceived = (max(idx)-numSamples/2-1)/numSamples*sampleRate;

% Plot the spectrum
sa = spectrumAnalyzer('SampleRate', sampleRate);
sa.Title = sprintf('Tone Expected at 80 kHz, Actually Received at %.3f kHz', ...
                   fReceived/1000);
receivedSig = reshape(receivedSig, [], 16); % Reshape into 16 columns
for i = 1:size(receivedSig, 2)
    sa(receivedSig(:,i));
end

%% Estimate and Apply the Value of FrequencyCorrection

rx.FrequencyCorrection = (fReceived - fRef) / (centerFreq + fRef) * 1e6;
msg = sprintf(['Based on the tone detected at %.3f kHz, ' ...
               'FrequencyCorrection of the receiver should be set to %.4f'], ...
               fReceived/1000, rx.FrequencyCorrection);
disp(msg);
rxRadioInfo = info(rx)

%% Receive and Visualize Signal

% Capture 10 frames, but only use the last frame to skip the transient 
% effects due to changing FrequencyCorrection 
disp(['Capture signal and verify frequency correction' newline])
for i = 1:10
    receivedSig = rx();
end

% Find the tone that corresponds to the 80 kHz transmitted tone
% fReceived2 should be very close to 80 kHz
y = fftshift(abs(fft(receivedSig)));
[~,idx] = findpeaks(y,'MinPeakProminence',max(0.5*y));
fReceived2 = (max(idx)-numSamples/2-1)/numSamples*sampleRate;

% Plot the spectrum
sa.Title = '3 Tones Received at 20, 40, and 80 kHz';
receivedSig = reshape(receivedSig, [], 16); % Reshape into 16 columns
for i = 1:size(receivedSig, 2)
    sa(receivedSig(:,i));
end
msg = sprintf('Tone detected at %.3f kHz\n', fReceived2/1000);
disp(msg);

%% Change FrequencyCorrection of the Transmitter
% Now we change the FrequencyCorrection property of the transmitter to
% simulate the effect that the transmitter's oscillator has drifted.

disp(['Change the FrequencyCorrection property of the transmitter to 1 to ' ...
      'simulate the effect that the transmitter''s oscillator has drifted'])
tx.FrequencyCorrection = 1; % 1 ppm
txRadioInfo = info(tx)
tx.transmitRepeat(s);

%% Receive and Visualize Signal

% Capture 10 frames, but use the last frame only to skip the transient 
% effects due to changing FrequencyCorrection 
disp(['Capture signal and observe the frequency offset' newline])
for i = 1:10
    receivedSig = rx();
end

% Find the tone that corresponds to the 80 kHz transmitted tone
% fReceived3 will not be close to 80 kHz because tx.FrequencyCorrection
% has been changed
y = fftshift(abs(fft(receivedSig)));
[~,idx] = findpeaks(y,'MinPeakProminence',max(0.5*y));
fReceived3 = (max(idx)-numSamples/2-1)/numSamples*sampleRate;

% Plot the spectrum
sa.Title = sprintf('Tone Expected at 80 kHz, Actually Received at %.3f kHz', ...
                   fReceived3/1000);
receivedSig = reshape(receivedSig, [], 16); % Reshape into 16 columns
for i = 1:size(receivedSig, 2)
    sa(receivedSig(:,i));
end

%% Estimate and Apply the Value of FrequencyCorrection
% We use the same method to estimate the required parts-per-million
% change to the baseband sample rate and the center frequency of the
% receiver. However, the estimated value needs to be combined appropriately
% with the current setting of FrequencyCorrection, which is nonzero.
% Since $(1+{p_1}/10^6)*(1+{p_2}/10^6) = 1 + ({p_1} + {p_2} + {p_1}*{p_2}*10^{-6})/10^6$,
% applying two changes $p_1$ and $p_2$ successively is equivalent to
% applying a single change of ${p_1} + {p_2} + {p_1}*{p_2}*10^{-6}$ with
% respect to the factory-calibrated condition.

rxRadioInfo = info(rx);
currentPPM = rxRadioInfo.FrequencyCorrection;
ppmToAdd = (fReceived3 - fRef) / (centerFreq + fRef) * 1e6;
rx.FrequencyCorrection = currentPPM + ppmToAdd + currentPPM*ppmToAdd/1e6;
msg = sprintf(['Based on the tone detected at %.3f kHz, ' ...
               'FrequencyCorrection of the receiver should be changed from %.4f to %.4f'], ...
               fReceived3/1000, currentPPM, rx.FrequencyCorrection);
disp(msg);
rxRadioInfo = info(rx)

%% Receive and Visualize Signal

% Capture 10 frames, but use the last frame only to skip the transient
% effects due to changing FrequencyCorrection 
disp(['Capture signal and verify frequency correction' newline])
for i = 1:10
    receivedSig = rx();
end

% Find the tone that corresponds to the 80 kHz transmitted tone
% fReceived4 should be very close to 80 kHz
y = fftshift(abs(fft(receivedSig)));
[~,idx] = findpeaks(y,'MinPeakProminence',max(0.5*y));
fReceived4 = (max(idx)-numSamples/2-1)/numSamples*sampleRate;

% Plot the spectrum
sa.Title = '3 Tones Received at 20, 40, and 80 kHz';
receivedSig = reshape(receivedSig, [], 16); % Reshape into 16 columns
for i = 1:size(receivedSig, 2)
    sa(receivedSig(:,i));
end
msg = sprintf('Tone detected at %.3f kHz', fReceived4/1000);
disp(msg);

% Release the radios
release(tx);
release(rx);