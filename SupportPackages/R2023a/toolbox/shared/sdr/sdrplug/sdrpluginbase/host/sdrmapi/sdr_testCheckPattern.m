function [errStat, errId, errStr] = sdr_testCheckPattern(driverHandle, len, patID) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('testCheckPattern', driverHandle, len, patID);

end
