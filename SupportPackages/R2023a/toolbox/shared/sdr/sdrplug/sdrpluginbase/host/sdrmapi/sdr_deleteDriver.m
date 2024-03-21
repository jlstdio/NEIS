function [errStat, errId, errStr] = sdr_deleteDriver(driverHandle)
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

    [errStat, errId, errStr] = sdr_mapiPrivate('deleteDriver', driverHandle);
end
