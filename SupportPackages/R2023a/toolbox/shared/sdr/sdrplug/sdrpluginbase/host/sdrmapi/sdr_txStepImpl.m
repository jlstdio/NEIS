function [metaDataSize, metaData, errStat, errId, errStr] = sdr_txStepImpl( ...
        driverHandle, dataSize, data)
%#codegen

%   Copyright 2014 The MathWorks, Inc.

[metaDataSize, metaData, errStat, errId, errStr] = ...
    sdr_mapiPrivate('txStepImpl', driverHandle, dataSize, data);

end
