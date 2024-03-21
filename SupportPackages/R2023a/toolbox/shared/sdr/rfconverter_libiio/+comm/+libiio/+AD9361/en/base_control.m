classdef base_control< matlabshared.libiio.base & coder.ExternalDependency
% comm.libiio.AD9361.base_control AD9361 matlabshared.libiio.base driver
%
% This block provides access to AD9361 base functionality

     
    %   Copyright 2014-2019 The MathWorks, Inc.

    methods
        function out=base_control
            %BASE_CONTROL Construct an instance of this class
        end

        function out=designCustomFilter(~) %#ok<STOUT>
            % designCustomFilter Design custom filter for AD9361-based
            % radios
            %
            % designCustomFilter(obj) launches the ADI Filter wizard
            % application for designing a custom filter.
            %
            % * For instructions on operating the ADI filter wizard, visit
            % the Analog Devices website at
            % https://wiki.analog.com/resources/eval/user-guides/ad-fmcomms2-ebz/software/filters
        end

    end
    properties
        % BISTLoopbackMode Loopback
        %
        % Set the Built-In Self-Test loopback mode.
        %   'Disabled': Disables BIST Loopback (default)
        %   'Digital Tx -> Digital Rx': Loops back the digital signals within
        %       the AD936x device (bypass RF stage)
        %   'RF Rx -> RF Tx': Loops back the incoming Rx RF signals to the RF
        %       Tx port (bypass FPGA)
        BISTLoopbackMode;

        % BISTSignalGen Signal generator mode
        %
        % Set the Built-In Self-Test signal generator mode.
        %   'Tone': Tone signal
        %   'PRBS': Pseudo random bit sequence
        BISTSignalGen;

        % BISTToneFreq Tone frequency (Hz)
        %
        % Set the the frequency of the tone when Built-In Self-Test signal
        % generator mode is set to 'Tone'.
        %   'Fs/32' (default)
        %   'Fs/16'
        %   'Fs*3/32'
        %   'Fs/8'
        BISTToneFreq;

        % BISTToneInject Test signal injection
        %
        % Set the Built-In Self-Test signal injection point.
        %   'Disabled': Disables BIST signal injection (default)
        %   'Tone Inject Tx': inject signal to transmit path
        %   'Tone Inject Rx': inject signal to receive path
        BISTToneInject;

        % BISTToneLevel Tone level (dB)
        %
        % Set the the amplitude of the tone when Built-In Self-Test signal
        % generator mode is set to 'Tone'.
        %   '0' (default)
        %   '-6'
        %   '-12'
        %   '-18'
        BISTToneLevel;

        % BasebandSampleRate Baseband sample rate (Hz)
        %
        % Specify the baseband sampling rate, in samples per second, as a double
        % precision scalar. The default value is 1e6.
        BasebandSampleRate;

        % Center frequency (Hz)
        %
        % Specify the RF center frequency for the Up/Down conversion as a
        % double precision scalar in Hz. The default value is 2.4e9.  This property is tunable.
        CenterFrequency;

        % CenterFrequencySource Source of center frequency
        %
        % LO source selection (dialog / input)
        CenterFrequencySource;

        % ChannelMapping Channel mapping
        %
        % Enabled channels, expressed as a vector. The default value is 1.
        %
        % Value is one of:
        %
        % A scalar N specifies that channel N is in use.
        % A vector [M, N, ...] specifies that multiple channels are in use.
        %
        % Valid values and value combinations are device-dependent.
        ChannelMapping;

        % ENSMPinControlMode ENSM pin control mode
        %
        % Set the Enable State Machine pin control mode.
        %   None: Both Tx/Rx enable controled via SPI
        %   Pinctrl: Tx and Rx enabled / disabled via ENABLE GPIO
        %   Pinctrl Independent: Tx enabled via TXNRX GPIO, Rx enabled
        %       via ENABLE gpio (FDD Only)
        ENSMPinControlMode;

        % Gain
        %
        % RF Hardware gain in dB
        Gain;

        % Source of gain
        %
        % Source of gain for the RF Converter
        GainSource;

        % Show Advanced Properties
        %
        % If set to true, will show the advanced properties for the object
        ShowAdvancedProperties;

        % Use custom filter
        %
        % Enable the use of a custom hardware filter
        UseCustomFilter;

        % FIR filter tap size
        %
        % This property should be populated by the filter wizard
        filtCoefficientSize;

        % FIR filter taps
        %
        % This property should be populated by the filter wizard
        filtCoefficients;

        % FIR filter decimation/interpolation factor
        %
        % This property should be populated by the filter wizard
        filtDecimInterpFactor;

        % FIR filter gain
        %
        % This property should be populated by the filter wizard
        filtGain;

        % FIR filter path rates
        %
        % Rates for: BBPLL DAC/ADC R2 R1 RF TX/RXSAMP
        % This property should be populated by the filter wizard
        filtPathRates;

        % RF bandwidth
        %
        % The Analog Cutoff Frequency
        %
        % This property should be populated by the filter wizard
        filtRFBandwidth;

        % Filter configuration struct
        %
        % The config struct from the ADI Filter Wizard
        % This property should be populated by the filter wizard
        filterConfigStruct;

    end
end
