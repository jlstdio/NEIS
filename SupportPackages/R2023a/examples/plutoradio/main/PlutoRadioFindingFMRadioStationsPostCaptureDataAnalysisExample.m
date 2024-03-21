%% Finding FM Radio Stations using Post-Capture Data Analysis
% Use the capture function and an ADALM-PLUTO radio to record RF signals 
% for post-capture processing in MATLAB(R). Save high sample rate RF data to 
% a file as baseband samples. Later, use the file with the Spectrum Analyzer
% System object to identify local FM broadcast radio stations. 

%% Configure SDR Hardware
% To configure your ADALM-PLUTO radio for host-radio communication, see 
% <docid:plutoradio_ug#bvn89q2-14 Guided Host-Radio Hardware Setup>.
%
% Attach an antenna suitable for the 88-108 MHz band to the RX port of the radio. 
% The FM radio band is outside the default tuning range for the ADALM-PLUTO 
% radio. The <docid:plutoradio_ref#bvusb68-1 configurePlutoRadio> function 
% enables you to extend the frequency range and use your ADALM-PLUTO radio 
% outside the qualified tuning range. The extended frequency range includes
% the full FM radio band.

configurePlutoRadio('AD9364');

%% Configure Receiver System Object
% Create an SDR receiver System object with the specified properties. The 
% specified center frequency corresponds to the centre of the FM Radio
% band. To mitigate nonlinearities in the RF filter response, set the baseband 
% sample rate significantly higher than the Nyquist sampling rate of 2*10 MHz.
% For this example the baseband sampling rate is set to the maximum permitted 
% value.

rx = sdrrx('Pluto');
rx.OutputDataType = 'Double';
rx.CenterFrequency = 98*10^6;
% Set greater than Nyquist sampling rate
rx.BasebandSampleRate = 6.144e+07;

%% Initiate Data Capture to File
% Call the |capture| function, specifying the receiver object, capture 
% duration, and file name.

capture(rx, 0.25, 'Seconds', 'filename', 'FMBandRFCapture.bb');

%% Post-Capture Data Analysis
% Create a <docid:comm_ref#bvb0lb6 Baseband File Reader> System object to 
% read the captured signal and extract the data from the file. Set the baseband
% file reader |SamplesPerFrame| to |bbrInfo.NumSamplesInData| to return 
% all captured samples in one step when reading the saved baseband RF Data.

bbr = comm.BasebandFileReader('FMBandRFCapture.bb');
bbrInfo = info(bbr);
bbr.SamplesPerFrame =  bbrInfo.NumSamplesInData;

%%
% Create a <docid:dsp_ref#bthj29x-1 dsp.SpectrumAnalyzer> System object to 
% display the captured RF data. Set the |dsp.SpectrumAnalyzer| object to 
% 'Spectrum and spectogram' and configure the spectrum analyzer to find 
% peaks which likely correspond to FM broadcast stations.

specScope = dsp.SpectrumAnalyzer('ViewType','Spectrum and spectrogram', ...
    'SampleRate', bbr.SampleRate, ...
    'FrequencySpan','Span and center frequency', ...
    'Span',(108-88)*10^6, ...
    'CenterFrequency',bbr.CenterFrequency, ...
    'FrequencyOffset',bbr.CenterFrequency, ...
    'TimeSpanSource','Property', ...
    'TimeSpan', bbr.SamplesPerFrame/bbr.SampleRate);

% Peak Finder Configuration
specScope.PeakFinder.MinHeight = -10;
specScope.PeakFinder.NumPeaks = 10;
specScope.PeakFinder.Enable = true;

specScope(bbr());

%%
% FM broadcast stations appear on the spectogram as vertical red lines 
% across the time domain. On close inspection, these lines move back and 
% forth in real time on the frequency axis due to the frequency modulation
% of the signal.
%
% Use the <docid:plutoradio_examples#example-plutoradioFMReceiverExample FM Broadcast Receiver>
% to tune into a FM broadcast station on a broadcast frequency identified 
% in this example.
%
% Copyright 2019 The MathWorks, Inc.