function [errStat, errId, errStr] = sdr_setConfiguration(driverHandle, setPropValsSize, setPropVals) 
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('setConfiguration', driverHandle, setPropValsSize, setPropVals);

end
