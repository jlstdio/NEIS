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

 %  Copyright 2015-2020 The MathWorks, Inc.

