function [infoStr, errStat, errId, errStr] = sdr_infoImpl(driverHandle)
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

    [infoStr, errStat, errId, errStr] = sdr_mapiPrivate('infoImpl', driverHandle);
end
