% sdrdev Create an SDR device.
%
%   DEV  = sdrdev(NAME) creates an object for interacting with the SDR
%   device identified by NAME.
%
%   LIST = sdrdev() returns the list of SDR devices available for the
%   currently installed support packages.
%
%   The list of available devices depends on the installed hardware support
%   packages and does not reflect what radios might actually be attached to
%   the host.  After creating an sdrdev device, use the info method to
%   verify host/hardware communication.
%
%   NOTE: System objects are used to receive or transmit data through the
%   radio.  To create System objects, see sdrrx and sdrtx.
%
%   Examples:
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
%     Create an SDR device and verify host/hardware communication.
%     >> dev = sdrdev('SDR Device X');
%     >> info(dev)
%
%  See also sdrrx, sdrtx
%
%  Copyright 2014-2020 The MathWorks, Inc.

 %  Copyright 2014-2020 The MathWorks, Inc.

