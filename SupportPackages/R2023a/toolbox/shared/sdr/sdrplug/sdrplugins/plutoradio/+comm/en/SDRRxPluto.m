classdef SDRRxPluto< comm.plutoradio.rx
% SDRRxPluto Receive data from an ADALM-PLUTO radio.
%
%   RX = sdrrx('Pluto') creates an SDR receiver System object, RX, that
%   receives data from an ADALM-PLUTO radio.
%
%   RX = sdrrx('Pluto',Name,Value) creates an SDR receiver System object,
%   RX, with the specified property Name set to the specified Value. You
%   can specify additional name-value pair arguments in any order as
%   (Name1,Value1,...,NameN,ValueN).
%
%   Step method syntax:
%
%   [Y,DV,OVR] = step(RX) receives signal and meta data from an ADALM-PLUTO radio.
%   The output signal, Y, is a column vector of complex double precision,
%   single precision or 16-bit integer values.  DV is a logical flag that
%   indicates if the data is valid.  OVR is a logical flag that reflects if
%   any samples have overrun during the step call.  If OVR is true, then Y
%   does not represent contiguous data.
%
%   Any outputs that are not of interest can be skipped with a '~'.
%
%   System objects may be called directly like a function instead of using
%   the step method. For example, y = step(RX) and y = RX() are equivalent.
%
%   SDRRxPluto methods:
%
%   step     - Receive data from the SDR board (see above)
%   capture  - Capture contiguous data from the SDR board
%   <a href="matlab:help matlab.System/info   ">info</a>     - Obtain SDR board information and quantized property values
%   release  - Allow property value and input characteristics changes
%   isLocked - Report locked status (logical)
%   designCustomFilter - Design a custom filter chain on the AD936x
%
%   SDRRxPluto properties:
%
%   DeviceName             - Name of the device
%   RadioID                - ID of the radio
%   CenterFrequency        - Desired center frequency in Hz
%   ChannelMapping         - Channels to receive on
%   GainSource             - Receive gain control mode
%   Gain                   - Receiver gain in dB
%   BasebandSampleRate     - Desired baseband sample rate in Hz
%   OutputDataType         - Data type of output complex samples
%   SamplesPerFrame        - Samples per frame
%   EnableBurstMode        - Ensure a contiguous set of samples without overrun
%   NumFramesInBurst       - Number of frames in contiguous burst
%   ShowAdvancedProperties - Show advanced properties
%
% Advanced SDRRxPluto properties:
%
%   UseCustomFilter            - Enable the use of a custom hardware filter, 
%                                designed using the designCustomFilter method
%   EnableQuadratureCorrection - Enable receive quadrature compensation
%   EnableRFDCCorrection       - Enable receive RF DC compensation
%   EnableBasebandDCCorrection - Enable receive baseband DC compensation
%   BISTLoopbackMode           - Built-in self-test loopback mode
%   BISTToneInject             - Built-in self-test signal injection mode
%
% The following properties are enabled when BISTToneInject is enabled
%
%   BISTSignalGen              - Select between Pseudo-random-binary-sequence (PRBS)
%                                and tone generation sources
%   BISTToneFreq               - BIST tone frequency in Hz
%   BISTToneLevel              - BIST tone level in dB, relative to maximum output amplitude
%
%   % Example 1:
%   %  Configure an ADALM-PLUTO radio with a Radio ID of 'usb:0' to
%   %  receive at 2.2 GHz with baseband sample rate of 800 ksps.
%
%   rx = sdrrx('Pluto', ...
%     'RadioID', 'usb:0', ...   % use first attached radio
%     'CenterFrequency', 2.2e9, ...
%     'BasebandSampleRate', 800e3);
%   for counter = 1:20
%     data = rx();
%   end
%
%   % Example 2: 
%   %  Use the info method to examine the actual values of CenterFrequency,
%   %  Gain, and BasebandSampleRate used by the radio, which may be 
%   %  different because of quantization.
%
%   rx = sdrrx('Pluto', ...
%     'CenterFrequency', 2.4e9, ...
%     'GainSource', 'Manual', ...
%     'Gain', 20, ...
%     'BasebandSampleRate', 960e3);
%   info(rx)
%
%   % Example 3:
%   %  Use the capture method to capture 2 seconds of RF data to a
%   %  comm.BasebandFileReader baseband file called RFCapture.bb.
%
%   rx = sdrrx('Pluto', ...
%     'RadioID', 'usb:0', ...
%     'CenterFrequency', 2.2e9, ...
%     'BasebandSampleRate', 800e3);
%   capture(rx, 2, 'Seconds', 'Filename', 'RFCapture.bb');
%
%   See also sdrrx, sdrtx, comm.SDRTxPluto.

 
% Copyright 2016-2019 The MathWorks, Inc.

    methods
        function out=SDRRxPluto
        end

        function out=infoImpl(~) %#ok<STOUT>
            %info Return characteristic information about the ADALM-PLUTO receiver
            %   S = info(RX) returns a structure containing characteristic
            %   information, S, about the ADALM-PLUTO receiver.  If the receiver object
            %   can connect to the radio, the structure has the following fields:
            %
            %   Status                  - Character vector stating 'Full information'
            %   CenterFrequency         - Actual center frequency, in Hz
            %   BasebandSampleRate      - Actual baseband sample rate, in sps
            %   SerialNum               - Character vector of the device's serial number
            %   GainControlMode         - Character vector stating 'AGC Slow Attack' or
            %                             'AGC Fast Attack' (only if the GainSource
            %                             property is 'AGC Slow Attack' or 'AGC Fast
            %                             Attack')
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
            %   the following additional fields:
            %
            %   EnableQuadratureTracking - Logical value showing use of IQ imbalance compensation
            %   EnableRFDCTracking       - Logical value showing use of an RF DC blocking filter
            %   EnableBasebandDCTracking - Logical value showing use of a baseband DC blocking filter
            %   FrequencyCorrection      - Frequency correction, in ppm
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
