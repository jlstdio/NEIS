classdef SDRTargetingBase< handle
% Copyright 2014-2019 The MathWorks, Inc.

     
% Copyright 2014-2019 The MathWorks, Inc.

    methods
        function out=SDRTargetingBase
        end

        function out=getToolName(~) %#ok<STOUT>
        end

        function out=setBoardInfo(~) %#ok<STOUT>
        end

    end
    properties
        buildArgs;

        targetName;

    end
end
