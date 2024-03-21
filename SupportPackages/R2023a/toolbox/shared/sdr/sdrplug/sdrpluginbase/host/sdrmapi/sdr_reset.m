function [errStat, errId, errStr] = sdr_reset(driverHandle, resetType, deviceID) 
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('reset', driverHandle, resetType, deviceID);

end
