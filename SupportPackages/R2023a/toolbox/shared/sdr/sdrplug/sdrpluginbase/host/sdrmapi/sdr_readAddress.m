function [rdata, rdwlen, errStat, errId, errStr] = sdr_readAddress(driverHandle, addr, wlen, winc, dwlen) 
%#codegen

%   Copyright 2013-2015 The MathWorks, Inc.

[rdata, rdwlen, errStat, errId, errStr] = sdr_mapiPrivate('readAddress', driverHandle, addr, wlen, winc, dwlen);

end
