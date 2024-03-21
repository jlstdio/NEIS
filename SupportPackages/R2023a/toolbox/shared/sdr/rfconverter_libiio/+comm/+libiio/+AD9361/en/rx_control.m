classdef rx_control< comm.libiio.AD9361.base
% comm.libiio.AD9361.rx AD9361 Receiver System Object
%
% This system object provides access to the AD9361 receive
% functionality

     
    % Copyright 2015-2018 The MathWorks, Inc.

    methods
        function out=rx_control
            % RX Constructor method for comm.libiio.AD9361.rx
            %
            % Returns the comm.libiio.AD9361.rx object
        end

        function out=getHeaderImpl(~) %#ok<STOUT>
        end

        function out=getIconImpl(~) %#ok<STOUT>
        end

        function out=setupImpl(~) %#ok<STOUT>
        end

    end
    properties
        % EnableBasebandDCCorrection Enable baseband DC correction
        %
        % Specify the use of a baseband DC blocking filter as a logical
        % value. The default value is true.
        EnableBasebandDCCorrection;

        % EnableQuadratureCorrection Enable quadrature correction
        %
        % Specify the use of IQ imbalance compensation as a logical value.
        % The default value is true.
        EnableQuadratureCorrection;

        % EnableRFDCCorrection Enable RF DC correction
        %
        % Specify the use of an RF DC blocking filter as a logical value.
        % The default value is true.
        EnableRFDCCorrection;

        % Gain Gain (dB)
        %
        % Specify gain as a double precision scalar with a resolution of 0.25 dB.
        % The default value is 10 dB. This property is tunable.
        Gain;

        % GainSource Source of gain
        %
        % Gain mode for AGC. The default value is AGC Slow Attack.
        % Specify the Gain source, as one of the following:
        % 1. 'AGC Slow Attack' (for signals with slowly changing power levels)
        % 2. 'AGC Fast Attack' (for signals with rapidly changing power levels)
        % 3. 'Manual' (for setting the gain manually with the Gain property)
        GainSource;

        % GainSourceBlock Source of gain
        %
        % Source of gain. The default value is AGC Slow Attack.
        GainSourceBlock;

        % ShowAdvancedProperties Show advanced properties
        %
        %  If set to true, will show the advanced properties for the object
        ShowAdvancedProperties;

    end
end
