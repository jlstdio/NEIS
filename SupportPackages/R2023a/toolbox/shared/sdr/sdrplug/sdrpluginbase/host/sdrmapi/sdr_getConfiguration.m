function [actualPropValsSize, actualPropVals, errStat, errId, errStr] = sdr_getConfiguration(driverHandle, whatCfgSize, whatCfg) 
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

[actualPropValsSize, actualPropVals, errStat, errId, errStr] = sdr_mapiPrivate('getConfiguration', driverHandle, whatCfgSize, whatCfg);

end
