function [metaDataSize, metaData, errStat, errId, errStr] = sdr_txStepImplSingle( ...
        driverHandle, dataSize, data)
%#codegen

%   Copyright 2014 The MathWorks, Inc.

[metaDataSize, metaData, errStat, errId, errStr] = ...
    sdr_mapiPrivate('txStepImplSingle', driverHandle, dataSize, data);

end
