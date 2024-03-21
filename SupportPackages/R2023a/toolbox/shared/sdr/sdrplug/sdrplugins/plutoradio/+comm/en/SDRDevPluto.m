classdef SDRDevPluto< handle & matlab.mixin.CustomDisplay
%  Copyright 2016-2018 The MathWorks, Inc.

   
  %  Copyright 2016-2018 The MathWorks, Inc.

    methods
        function out=SDRDevPluto
        end

        function out=launchSetupWizard(~) %#ok<STOUT>
            %launchSetupWizard Launch a wizard to set up the host and SDR device for proper communication
            %
            % Interactively go through the necessary steps of setting up the
            % host and SDR hardware system by launching a graphical wizard.
            %
            % Example:
            %   dev = sdrdev('Pluto');
            %   launchSetupWizard(dev);
        end

    end
    properties
        %DeviceName The string identifier for this SDR device
        %
        DeviceName;

        RadioID;

    end
end
