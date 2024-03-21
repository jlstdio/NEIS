%FINDPLUTORADIO Find ADALM-PLUTO radios connected to host computer via USB interface
%   A = FINDPLUTORADIO() returns a structure array, A, with the following
%   fields describing all ADALM-PLUTO radios connected to the host computer via
%   USB interface:
%
%     RadioID   - Radio identification number as a character vector starting
%                 with 'usb:'
%     SerialNum - Serial number of the radio, as a hexadecimal character vector
%
%   % Example:
%   %   Find the radio ID and serial number of all ADALM-PLUTO radios
%   %   connected to the host via USB interface
%   a = findPlutoRadio()
%
%   See also sdrrx, sdrtx, comm.SDRRxPluto, comm.SDRTxPluto.

 
%   Copyright 2017 The MathWorks, Inc.

