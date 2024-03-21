function [errStat, errId, errStr] = sdr_testGeneratePattern(driverHandle, len, patID) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('testGeneratePattern', driverHandle, len, patID);

end
