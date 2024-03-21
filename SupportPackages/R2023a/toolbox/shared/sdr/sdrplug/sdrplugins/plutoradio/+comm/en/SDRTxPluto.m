classdef SDRTxPluto< comm.plutoradio.tx
% SDRTxPluto Transmit data to an ADALM-PLUTO radio.
%
%   TX = sdrtx('Pluto') creates an SDR transmitter System object, TX, that
%   transmits data to an ADALM-PLUTO radio.  Although the ADALM-PLUTO transmitter
%   System object sends data to an ADALM-PLUTO radio, the object acts as a sink in
%   MATLAB.
%
%   TX = sdrtx('Pluto',Name,Value) creates an SDR transmitter
%   System object, TX, with the specified property Name set to the
%   specified Value. You can specify additional name-value pair arguments
%   in any order as (Name1,Value1,...,NameN,ValueN).
%
%   Step method syntax:
%
%   step(TX, DATA) transmits signal to a radio. Input signal, DATA, is a
%   column vector of complex double precision, single precision or 16-bit
%   integer values.
%
%   UNDR = step(TX, DATA) returns the logical value UNDR that reflects if
%   any samples have underrun during the step call.  If UNDR is true, the
%   RF will not represent a contiguous signal from the host to the antenna.
%
%   System objects may be called directly like a function instead of using
%   the step method. For example, y = step(TX, x) and y = TX(x) are
%   equivalent.
%
%   SDRTxPluto methods:
%
%   step           - Transmit data to the ADALM-PLUTO radio
%   <a href="matlab:help matlab.System/info   ">info</a>           - Obtain radio information and quantized property values
%   release        - Allow property value and input characteristics changes
%   isLocked       - Report locked status (logical)
%   designCustomFilter - Design a custom filter chain on the AD936x
%   transmitRepeat - Download a waveform to the radio and repeatedly 
%                    transmit it over the air
%
% SDRTxPluto properties:
%   DeviceName                - Name of the device
%   RadioID                   - ID of the radio
%   CenterFrequency           - Desired center frequency in Hz
%   Gain                      - Transmit gain in dB
%   ChannelMapping            - Channels to transmit on
%   BasebandSampleRate        - Desired baseband sample rate in Hz
%   ShowAdvancedProperties    - Show advanced properties
%
% Advanced SDRTxPluto properties:
%   UseCustomFilter           - Enable the use of a custom hardware filter, 
%                               designed using the designCustomFilter method
%   DataSourceSelect          - Select between the host or direct digital synthesis (DDS) data sources
%   FrequencyCorrection       - Frequency correction in ppm
%   BISTLoopbackMode          - Built-in-self-test loopback mode
%   BISTToneInject            - Built-in-self-test signal injection mode
% 
% The following properties are enabled when DDS is selected as data source:
%
%   DDSTone1Freq              - Transmit DDS tone 1 frequency (Hz)
%   DDSTone2Freq              - Transmit DDS tone 2 frequency (Hz)
%   DDSTone1Scale             - Transmit DDS tone 1 scale value
%   DDSTone2Scale             - Transmit DDS tone 2 scale value
%
%   % Example 1:
%   %  Configure an ADALM-PLUTO radio with a Radio ID of 'usb:0' to
%   %  transmit at 2.2 GHz with baseband sample rate of 800 ksps.
%
%   tx = sdrtx('Pluto', ...
%     'RadioID', 'usb:0', ...  % use first attached radio
%     'CenterFrequency', 2.2e9, ...
%     'BasebandSampleRate', 800e3);
%   modulator = comm.DPSKModulator('BitInput',true);
%   for counter = 1:20
%     data = randi([0 1], 30, 1);
%     modSignal = modulator(data);
%     tx(modSignal);
%   end
%
%   % Example 2: 
%   %  Use the info method to examine the actual values of CenterFrequency,
%   %  Gain, and BasebandSampleRate used by the radio, which may be 
%   %  different because of quantization.
%
%   tx = sdrtx('Pluto', ...
%     'CenterFrequency', 2.4e9, ...
%     'Gain', -20, ...
%     'BasebandSampleRate', 960e3);
%   info(tx)
%
%   % Example 3:
%   %  Configure an ADALM-PLUTO radio with a Radio ID of 'usb:0' to repeatedly
%   %  transmit at 2.2 GHz with baseband sample rate of 800 ksps.
%
%   tx = sdrtx('Pluto', ...
%     'RadioID', 'usb:0', ...  % use first attached radio
%     'CenterFrequency', 2.2e9, ...
%     'BasebandSampleRate', 800e3);
%   modulator = comm.DPSKModulator('BitInput',true);
%   data = randi([0 1], 30, 1);
%   modSignal = modulator(data);
%   transmitRepeat(tx, modSignal);
%
%   See also sdrtx, sdrrx, comm.SDRRxPluto.

 
% Copyright 2016-2019 The MathWorks, Inc.

    methods
        function out=SDRTxPluto
        end

        function out=infoImpl(~) %#ok<STOUT>
            %info Return characteristic information about the ADALM-PLUTO transmitter
            %   S = info(TX) returns a structure containing characteristic
            %   information, S, about the ADALM-PLUTO transmitter.  If the receiver object
            %   can connect to the radio, the structure has the following fields:
            %
            %   Status                  - Character vector stating 'Full information'
            %   CenterFrequency         - Actual center frequency, in Hz
            %   BasebandSampleRate      - Actual baseband sample rate, in sps
            %   SerialNum               - Character vector of the device's serial number
            %   Gain                    - Actual gain, in dB (only if the GainSource
            %                             property is 'Manual')
            %   RadioFirmwareVersion    - String of the firmware version loaded on the
            %                             device
            %   ExpectedFirmwareVersion - String of the expected firmware version to be
            %                             loaded on the device
            %   HardwareVersion         - String of the PCB version along with the
            %                             model variant (if exists)
            %
            %   If the ShowAdvancedProperties property is true, the structure has
            %   the following additional field:
            %
            %   FrequencyCorrection - Frequency correction, in ppm
            %
            %   If the receiver object cannot connect with the radio, the structure
            %   has only the following field:
            %
            %   Status - Character vector stating 'No connection with device'
        end

        function out=processTunedPropertiesImpl(~) %#ok<STOUT>
        end

        function out=setupImpl(~) %#ok<STOUT>
        end

        function out=writeXOCorrectionValue(~) %#ok<STOUT>
        end

    end
    properties
        % FrequencyCorrection Frequency correction (ppm)
        % Specify the frequency correction value in ppm as a double precision scalar.
        % The valid range is [-200, 200] ppm. The default value is 0, which
        % corresponds to the factory-calibrated setting of the radio. This
        % property value specifies the parts-per-million change to the baseband
        % sample rate and the center frequency.
        FrequencyCorrection;

    end
end
