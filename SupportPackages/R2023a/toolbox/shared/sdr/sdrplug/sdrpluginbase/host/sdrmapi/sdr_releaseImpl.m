function [errStat, errId, errStr] = sdr_releaseImpl(driverHandle)
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

    [errStat, errId, errStr] = sdr_mapiPrivate('releaseImpl', driverHandle);
end
