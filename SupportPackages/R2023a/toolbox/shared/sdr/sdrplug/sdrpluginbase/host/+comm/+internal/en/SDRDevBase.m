classdef SDRDevBase< handle & matlab.mixin.CustomDisplay
% SDRDevBase Internal base class for SDRDevXX classes

 %  Copyright 2014-2018 The MathWorks, Inc.

    methods
        function out=SDRDevBase
        end

        function out=getFooter(~) %#ok<STOUT>
            %if (isscalar(obj))
            %    s = [char(10) '<a href="matlab:methods(''' class(obj) ''')">Methods</a>' char(10) char(10)];
            %else
        end

        function out=getHeader(~) %#ok<STOUT>
        end

        function out=getPropertyGroups(~) %#ok<STOUT>
        end

        function out=testConnection(~) %#ok<STOUT>
            % TESTCONNECTION Test the connection to the Zynq device
            %
            %    TESTCONNECTION will verify the connection between your
            %    host NIC and a Zynq-based radio at the IP address defined in the
            %    device object. It will check that the correct embedded software
            %    version and RF card are present. Also, some data path tests will be
            %    performed to ensure a full working radio connection.
            %
            %    TESTCONNECTION(HOSTIPADDR) will additionally test the setup of
            %    your host NIC.  HOSTIPADDR is the IP address of the host NIC,
            %    configured during initial setup. This must be provided as a
            %    string, in dotted-decimal format.
            %
            %    It is required that a valid image is present on the board SD card.
            %
            %    For RF loopback tests a cable or antennas must be connected to the
            %    transmit and receive connectors.
            %
            %    Example:
            %      Test the connection between the host and the Zynq device.
            %
            %      dev = sdrdev('ZC706 and FMCOMMS2/3/4');
            %      testConnection(dev);
            %
            %      dev = sdrdev('ZC706 and FMCOMMS2/3/4');
            %      testConnection(dev, '192.168.3.1');
            %
            %    See also info, downloadImage.
        end

    end
    properties
        %DeviceName The string identifier for this SDR device
        %
        DeviceName;

    end
end
