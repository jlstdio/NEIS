function [metaDataSize, metaData, errStat, errId, errStr] = sdr_txStepImplInt16( ...
        driverHandle, dataSize, data)
%#codegen

%   Copyright 2014 The MathWorks, Inc.

[metaDataSize, metaData, errStat, errId, errStr] = ...
    sdr_mapiPrivate('txStepImplInt16', driverHandle, dataSize, data);

end
