classdef base< handle
% comm.plutoradio.base PlutoSDR base driver
%
% This block provides access to PlutoSDR base functionality

 
    %   Copyright 2017-2022 The MathWorks, Inc.

    methods
        function out=base
            % BASE constructor method for comm.plutoradio.base
            %
            % Returns the comm.plutoradio.base object
        end

    end
    properties
        % Radio ID
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
