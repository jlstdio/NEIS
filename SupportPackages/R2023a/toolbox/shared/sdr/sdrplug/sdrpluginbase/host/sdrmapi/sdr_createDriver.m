function [driverHandle, errStat, errId, errStr] = sdr_createDriver(creationArgsSize, creationArgs) 
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

[driverHandle, errStat, errId, errStr] = sdr_mapiPrivate('createDriver', creationArgsSize, creationArgs);

end
