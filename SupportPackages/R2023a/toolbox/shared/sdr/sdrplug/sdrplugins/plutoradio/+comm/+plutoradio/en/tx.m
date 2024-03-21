classdef tx< comm.libiio.AD9361.tx & comm.plutoradio.base
% comm.plutoradio.tx Transmit data to an ADALM-PLUTO radio.
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
%   comm.plutoradio.tx methods:
%
%   step           - Transmit data to the ADALM-PLUTO radio
%   <a href="matlab:help matlab.System/info   ">info</a>           - Obtain radio information and quantized property values
%   release        - Allow property value and input characteristics changes
%   isLocked       - Report locked status (logical)
%   transmitRepeat - Download a waveform to the radio and repeatedly
%                    transmit it over the air
%
% comm.plutoradio.tx properties:
%   DeviceName         - Name of the device
%   RadioID            - ID of the radio
%   CenterFrequency    - Desired center frequency in Hz
%   Gain               - Transmit gain in dB
%   ChannelMapping     - Channels to transmit on
%   BasebandSampleRate - Desired baseband sample rate in Hz
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

 
    % Copyright 2016-2021 The MathWorks, Inc.

    methods
        function out=tx
            % TX Constructor method for comm.plutoradio.tx
            %
            % Returns the comm.plutoradio.tx object
        end

        function out=designCustomFilter(~) %#ok<STOUT>
        end

        function out=getHeaderImpl(~) %#ok<STOUT>
        end

        function out=getIconImpl(~) %#ok<STOUT>
        end

    end
    properties
        %AD9361MaxSampRate -  Hz
        AD9361MaxSampRate;

        %AD9361MinSampRate -  Hz
        AD9361MinSampRate;

        %DeviceName Device name
        %  This property identifies the device as a 'Pluto' transmitter.  It is
        %  read-only.
        DeviceName;

        % RadioID 
        % 
        % Radio identification number
        %   Specify the radio identification number as a character vector, as
        %   either:
        %   1. (recommended) A device-independent index, with the prefix usb:,
        %      such as 'usb:0', 'usb:1', 'usb:2', ..., indicating the first,
        %      second, third, ..., attached ADALM-PLUTO radio, respectively
        %   2. An IP address, with the prefix ip:, such as 'ip:192.168.2.1'
        %   3. A serial number, represented by a hexadecimal character vector
        %      with the prefix sn:, such as
        %      'sn:100000235523730700230031090216eaeb'
        %   The default value is 'usb:0'.
        RadioID;

    end
end
