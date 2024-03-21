function [rdata, rdlen, errStat, errId, errStr] = sdr_testLoopback(driverHandle, len, data) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[rdata, rdlen, errStat, errId, errStr] = sdr_mapiPrivate('testLoopback', driverHandle, len, data);

end
