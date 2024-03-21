function [errStat, errId, errStr] = sdr_processTunedPropertiesImpl(driverHandle, tunablePropsSize, tunableProps) 
%#codegen

%   Copyright 2013-2014 The MathWorks, Inc.

[errStat, errId, errStr] = sdr_mapiPrivate('processTunedPropertiesImpl', driverHandle, tunablePropsSize, tunableProps);

end
