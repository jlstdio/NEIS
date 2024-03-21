function [errStat, errId, errStr] = sdr_writeAddress(driverHandle, addr, wlen, winc, dwlen, data) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('writeAddress', driverHandle, addr, wlen, winc, dwlen, data);

end
