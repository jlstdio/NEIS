function obj = sdrrx(varargin)
%SDRRX Create an SDR receiver System object
%
%  h = SDRRX(NAME) returns an SDR receiver System object for the named radio
%
%  h = SDRRX(NAME, Name1, Val1, ...) returns an SDR receiver System object
%        for the named radio initialized with the Name/Value pairs specified.
%        The valid Name/Value pairs depends on the named radio.
%
%  NOTE: An SDR device object is used to set up the host and hardware in
%  preparation for receiving or transmitting data.  To create an SDR device
%  object see sdrdev.
%
%  Example:
%     Show a list of installed SDR devices:
%     >> list = sdrdev()
%     list =
%         'SDR Device 1'
%         'SDR Device 2'
%          ...
%          ...
%          ...
%         'SDR Device X'
%
%    Create an SDR receiver for receiving data from the SDR radio hardware.
%    >> h = sdrrx('SDR Device X', 'CenterFrequency', 2.4e9);
%
%  See also sdrdev, sdrtx.
%
%  Copyright 2015-2020 The MathWorks, Inc.

%#codegen

coder.extrinsic('sprintf');
coder.extrinsic('exist');
coder.extrinsic('sdr.internal.SDRZFeature');

existDir = 0;

existDir = exist('xilinxzynqbasedradio_hspdef','dir');

if (existDir==7)
    
    zynqradioIIO = sprintf('\n\t%s\n\t%s\n' ...
        , '''AD936x''' ...
        , '''FMCOMMS5''');
    
else
    zynqradioIIO = '';
end

existDir = exist('usrpembeddedseriesradio_hspdef','dir');

if (existDir==7)
    usrpRadioIIO = sprintf('\t%s\n' ...
        , '''E3xx''');
else
    usrpRadioIIO = '';
end

existDir = exist('plutoradio_hspdef','dir');

if (existDir==7)
    plutoDeviceNames = sprintf('\t%s\n' ...
        , '''Pluto''');
else
    plutoDeviceNames = '';
end
deviceNames = [zynqradioIIO usrpRadioIIO plutoDeviceNames];

if (nargin > 0)
    devName = varargin{1};
else
    error('Specify an SDR device name.  Valid names include:\n%s',deviceNames);
end

switch devName
    case 'Pluto'
        obj = comm.SDRRxPluto(varargin{2:end});
    case 'AD936x'
        obj = comm.SDRRxAD936x(varargin{2:end});
    case 'FMCOMMS5'
        obj = comm.SDRRxFMCOMMS5(varargin{2:end});
    case 'E3xx'
        obj = comm.SDRRxE3xx(varargin{2:end});
        
    otherwise
        error('Unknown SDR device name.  Valid names include:\n%s',deviceNames);
end
end
