classdef base< matlab.System & matlabshared.libiio.context & matlabshared.libiio.channel & matlabshared.libiio.device & matlabshared.libiio.buffer & matlabshared.libiio.top
% matlabshared.libiio.base Base System Object for libIIO support
%
% This abstract system object defines the APIs necessary to use libIIO
% for MATLAB/Simulink simulation as well as codegen on a Linux target

     
    % Copyright 2016-2022 The MathWorks, Inc.

    methods
        function out=base
            % BASE constructor method for matlabshared.libiio.base
            %
            % Returns the matlabshared.libiio.base object
        end

    end
    properties
        % Timeout for I/O
        %
        % Timeout for I/O operations (in seconds)
        % 0 = non-blocking (or default context timeout)
        % Inf = infinite
        DataTimeout;

        % Frame size
        %
        % Size of the frame in samples
        SamplesPerFrame;

        buffersAvailable;

        % Number of channels
        %
        % Number of enabled channels
        channelCount;

        % Data type for the output data
        %
        % A String Representing the data type
        dataTypeStr;

        % Device name
        %
        % Name of the libIIO device
        devName;

        % Enable simulation I/O
        %
        % If true, connects to libIIO device during simulation
        enIO;

        % Kernel buffers count
        %
        % The number of buffers allocated in the kernel for data transfers
        kernelBuffersCount;

        % URI - remote host URI
        %
        % Hostname or IP address of remote libIIO device
        uri;

    end
end
