classdef tx< comm.libiio.AD9361.tx_control
% comm.libiio.AD9361.tx AD9361 Transmitter System Object
%
% This system object provides access to the AD9361 transmit
% functionality

     
    % Copyright 2015-2018 The MathWorks, Inc.

    methods
        function out=tx
            % TX Constructor method for comm.libiio.AD9361.tx
            %
            % Returns the comm.libiio.AD9361.tx object
        end

        function out=transmitRepeat(~) %#ok<STOUT>
            % transmitRepeat Download a waveform to the radio and repeatedly transmit it over the air
            % 
            % transmitRepeat(tx,txWaveform) downloads a waveform signal, txWaveform, to
            % the radio hardware associated with the transmitter System object, tx, and
            % transmits it repeatedly over the air. The waveform signal should match
            % the formats supported by the step method. The waveform is written into
            % hardware memory and then transmitted over the air repeatedly without gaps
            % until the release method is called or a new waveform is downloaded.
        end

    end
    properties
        % EnablePrimer Enable TX Buffer priming
        %
        % Pre-load the Tx buffers with zero-data
        EnablePrimer;

        % EnableTransmitRepeat Enable Transmit/Repeat mode
        %
        % Transmit and repeat a single buffer
        EnableTransmitRepeat;

        % UnderflowOutputPort Enable output port for underflow indicator
        %
        % Enables a port to indicate underflow
        UnderflowOutputPort;

        % kernelBuffersCount Kernel buffer depth
        %
        % Number of buffers used in the kernel circular queue
        kernelBuffersCount;

    end
end
