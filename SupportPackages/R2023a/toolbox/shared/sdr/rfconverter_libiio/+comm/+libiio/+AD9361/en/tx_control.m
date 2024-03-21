classdef tx_control< comm.libiio.AD9361.base
%TX_CONTROL Summary of this class goes here
%   Detailed explanation goes here
    methods
        function out=tx_control
            % TX Constructor method for comm.libiio.AD9361.tx_control
            %
            % Returns the comm.libiio.AD9361.tx object
        end

        function out=getHeaderImpl(~) %#ok<STOUT>
        end

        function out=getIconImpl(~) %#ok<STOUT>
        end

    end
    properties
        % DDSTone1Freq Tone 1 Frequency (Hz)
        %
        % Tone 1 frequency for DDS. This property is tunable.
        DDSTone1Freq;

        % DDSTone1Scale Tone 1 Scale [0-1]
        %
        % Tone 1 Scale (fraction of fullscale) for DDS. This property is tunable.
        DDSTone1Scale;

        % DDSTone2Freq Tone 2 Frequency (Hz)
        %
        % Tone 2 frequency for DDS. This property is tunable.
        DDSTone2Freq;

        % DDSTone2Scale Tone 2 Scale [0-1]
        %
        % Tone 2 Scale (fraction of fullscale) for DDS. This property is tunable.
        DDSTone2Scale;

        % DataSourceSelect Data source select
        %
        % Source for transmit data.
        % 1. 'Input Port'
        % 2. 'DDS'
        DataSourceSelect;

        % Gain Gain (dB)
        %
        % Specify gain as a double precision scalar with a resolution of 0.25 dB.
        % The default value is -10 dB. This property is tunable.
        Gain;

        % GainSource Source of gain
        %
        % Source of gain.
        % 1. 'Dialog'
        % 2. 'Input Port'
        GainSource;

        % ShowAdvancedProperties Show Advanced Properties
        %
        % If set to true, will show the advanced properties for the object
        ShowAdvancedProperties;

    end
end
