function [dataSize, data, metaDataSize, metaData, errStat, errId, errStr] = sdr_rxStepImpl( ...
        driverHandle, bytesPerFrame)
%#codegen

%   Copyright 2014 The MathWorks, Inc.

[dataSize, data, metaDataSize, metaData, errStat, errId, errStr] = ...
    sdr_mapiPrivate('rxStepImpl', driverHandle, bytesPerFrame);

end
