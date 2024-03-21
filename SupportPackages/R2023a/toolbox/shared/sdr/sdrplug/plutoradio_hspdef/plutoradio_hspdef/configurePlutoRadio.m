function varargout = configurePlutoRadio(chipset, varargin)
%configurePlutoRadio Configure ADALM-PLUTO radio firmware
%   configurePlutoRadio(CHIPSET) configures the ADALM-PLUTO radio with
%   RadioID 'usb:0' to operate in the specified CHIPSET mode. The radio
%   must be connected to computer running this command. CHIPSET must be one
%   of 'AD9364' or 'AD9363'.
%
%   configurePlutoRadio(CHIPSET,ID) configures the ADALM-PLUTO radio
%   with RadioID, ID.
%
%   S = configurePlutoRadio(...) returns true if configuration is
%   successful. 
%
%   If CHIPSET is set to 'AD9363', which is factory default value, LO
%   tuning range is between 325 MHz and 3.8 GHz with a maximum bandwidth of
%   20 MHz. If CHIPSET is set to 'AD9364', LO tuning range is between 70
%   MHz and 6 GHz with a maximum bandwidth of 56 MHz.
%
%   % Example: 
%   %   Connect one ADALM-PLUTO radio to the host via a USB interface. 
%   %   Execute configurePlutoRadio with the input argument 'AD9464' to 
%   %   change radio configuration to operate over the wider bandwidth and 
%   %   higher sampling rate.
%   configurePlutoRadio('AD9364')

%   Copyright 2017-2018 The MathWorks, Inc.

narginchk(1,2)

dev = sdrdev('Pluto');

ip = inputParser;
addRequired(ip,'chipset',...
  @(chipset)validateChipset(chipset));
addOptional(ip,'radioID','usb:0',...
  @(radioID)validateRadioID(radioID));
parse(ip,chipset,varargin{:})

config = plutoradio.internal.RadioConfigurationManager(ip.Results.radioID);

success = set(config, ip.Results.chipset);

if nargout > 0
  varargout{1} = success;
end
end

function success = validateChipset(chipset)
  validatestring(chipset,{'AD9364','AD9363'},mfilename,'CHIPSET');
  success = true;
end

function success = validateRadioID(radioID)
  rx = sdrrx('Pluto');
  set(rx,'RadioID',radioID);
  success = true;
end
