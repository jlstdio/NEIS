function p = sdrplugin_customization()
% SDRPLUGIN_CUSTOMIZATION Specify required information for the SDRPluginManager
%
% The SDRPLUGIN_CUSTOMIZATION file allows for the dynamic "plugging in" of SDR
% integrations into MATLAB.  It provides the required definitions for the
% SDRPluginManager to do its work.
%
% An SDR plugin consists of the following objects:
%  - A device object              
%       Provides utilities for setup and basic hw interaction.
%  - A receiver System object 
%       Provides a receive streaming data interface from the hw.
%  - A transmitter System object
%       Provides a transmit streaming data interface to the hw.
%  - Targeting support objects (if the plugin supports targeting):
%       - A build args object
%           Provides configuration options for an FPGA build
%       - A target workflow object
%           Provides means to create FPGA with user logic          
%
% The objects are created via the following factory functions:
%  - sdrdev     (customer-documented)
%  - sdrrx      (customer-documented)
%  - sdrtx      (customer-documented)
%  - SDRPluginManager.getPluginObj   (internal)
%
% See also sdrplugin.internal.SDRPluginManager
%

% Copyright 2016-2017 The MathWorks, Inc.

    % -------------- customer visible info ----------------
    % public props
    p.DeviceName        = 'Pluto';  % arg val to sdrdev, sdrrx, sdrtx
    p.TargetingName     = p.DeviceName;            % HDLWA targeting platform drop-down list
    % -----------------------------------------------------

    % -------------- internal use info --------------------
    p.OwningHSP         = 'ADALM-Pluto Radio'; % must match support_package_registry.xml "name" field
    p.DesignName        = 'Pluto';            % for testing: shorthand name; class name suffix
    p.Root              = fileparts(mfilename('fullpath'));

    p.SDRDevObj         = comm.SDRDevPluto(p); % does it need the arg?
    p.SDRRxObj          = 'comm.SDRRxPluto';
    p.SDRTxObj          = 'comm.SDRTxPluto';
    
end
