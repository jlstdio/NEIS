function [errStat, errId, errStr] = sdr_setProperty(driverHandle, propID, dlen, data) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('setProperty', driverHandle, propID, dlen, data);

end
