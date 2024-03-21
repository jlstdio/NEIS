classdef(Enumeration) SDRPluginStatusT < int32

%   Copyright 2013-2014 The MathWorks, Inc.

    enumeration
        SDRDriverError(0),
        SDRDriverSuccess(1)
    end
    methods (Static=true)
        function retVal = getHeaderFile()
            retVal = 'sdrcapi.h';
        end
        function retVal = addClassNameToEnumNames()
            retVal = false;
        end
    end
end
