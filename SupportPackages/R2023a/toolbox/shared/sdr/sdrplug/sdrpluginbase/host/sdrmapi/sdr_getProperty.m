function [rdata, rdlen, errStat, errId, errStr] = sdr_getProperty(driverHandle, propID) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[rdata, rdlen, errStat, errId, errStr] = sdr_mapiPrivate('getProperty', driverHandle, propID);

end
