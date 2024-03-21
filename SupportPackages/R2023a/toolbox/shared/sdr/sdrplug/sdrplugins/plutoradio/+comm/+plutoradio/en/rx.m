classdef rx< comm.libiio.AD9361.rx & comm.plutoradio.base
% comm.plutoradio.rx Receive data from an ADALM-PLUTO radio.
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
%   comm.plutoradio.rx methods:
%
%   step     - Receive data from the SDR board (see above)
%   <a href="matlab:help matlab.System/info   ">info</a>     - Obtain SDR board information and quantized property values
%   release  - Allow property value and input characteristics changes
%   isLocked - Report locked status (logical)
%
%   comm.plutoradio.rx properties:
%
%   DeviceName             - Name of the device
%   RadioID                - ID of the radio
%   CenterFrequency        - Desired center frequency in Hz
%   GainSource             - Receive gain control mode
%   ChannelMapping         - Channels to receive on
%   Gain                   - Receiver gain in dB
%   BasebandSampleRate     - Desired baseband sample rate in Hz
%   OutputDataType         - Data type of output complex samples
%   SamplesPerFrame        - Samples per frame
%   ShowAdvancedProperties - Show advanced properties
%
% Advanced comm.plutoradio.rx properties:
%   EnableQuadratureTracking - Enable receive quadrature tracking
%   EnableRFDCTracking       - Enable receive RF DC tracking
%   EnableBasebandDCTracking - Enable receive baseband DC tracking
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
%   See also sdrrx, sdrtx, comm.plutoradio.tx.

 
    % Copyright 2017-2021 The MathWorks, Inc.

    methods
        function out=rx
            % RX Constructor method for comm.plutoradio.rx
            %
            % Returns the comm.plutoradio.rx object
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
        %  This property identifies the device as a 'Pluto' receiver.  It is
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
