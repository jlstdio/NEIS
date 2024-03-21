function [flatAddrList, errStat, errId, errStr] = sdr_findRadios(findArgsSize, findArgs)
%FINDRADIOS Report all SDR devices connected to the host computer
%   A = FINDRADIOS() returns a comma delimited list of IP addresses, A, that
%   belong to SDR devices connected to the host computer.
%   

%   Copyright 2011-2014 The MathWorks, Inc.

%#codegen

    [flatAddrList, errStat, errId, errStr] = sdr_mapiPrivate('findRadios', findArgsSize, findArgs);
end
