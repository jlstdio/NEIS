%SDRTX Create an SDR transmitter System object
%
%  h = SDRTX(NAME) returns an SDR transmitter System object for the named radio
%
%  h = SDRTX(NAME, Name1, Val1, ...) returns an SDR transmitter System object
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
%    Create an SDR transmitter for transmitting data to the SDR radio
%    hardware.
%    >> h = sdrtx('SDR Device X', 'CenterFrequency', 2.4e9);
%
%  See also sdrdev, sdrrx.
%
%  Copyright 2015-2020 The MathWorks, Inc.

 %  Copyright 2015-2020 The MathWorks, Inc.

