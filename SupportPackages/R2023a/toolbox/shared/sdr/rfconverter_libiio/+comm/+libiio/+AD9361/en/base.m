classdef base< comm.libiio.AD9361.base_control
% comm.libiio.AD9361.base AD9361 matlabshared.libiio.base driver
%
% This block provides access to AD9361 base functionality

     
    %   Copyright 2014-2020 The MathWorks, Inc.

    methods
        function out=base
            % BASE Constructor method for comm.libiio.AD9361.base
        end

    end
    properties
        % Columns as Channels
        %
        % Output the data using columns as channels. This is the standard
        % MATLAB representation of channels, but differs from the hardware
        % in-memory representations, and thus has a computational cost.
        ColsAsChans;

        % DataTimeout Data timeout (sec)
        %
        % Timeout for I/O operations (in seconds).
        % 0 = non-blocking
        % Inf = infinite (default)
        DataTimeout;

        % Output data type
        %
        % I/O data type (complex data)
        OutputDataType;

    end
end
