function [metaDataSize, metaData, errStat, errId, errStr] = sdr_txStepImplDouble( ...
        driverHandle, dataSize, data)
%#codegen

%   Copyright 2014 The MathWorks, Inc.

[metaDataSize, metaData, errStat, errId, errStr] = ...
    sdr_mapiPrivate('txStepImplDouble', driverHandle, dataSize, data);

end
