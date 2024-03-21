function [flatAddrList, errStat, errId, errStr] = sdr_reportDrivers()

%   Copyright 2013-2014 The MathWorks, Inc.

%#codegen

    [flatAddrList, errStat, errId, errStr] = sdr_mapiPrivate('reportDrivers');
end
