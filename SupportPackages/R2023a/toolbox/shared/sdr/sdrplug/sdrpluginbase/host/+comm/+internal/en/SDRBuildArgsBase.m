classdef SDRBuildArgsBase< handle
%  Copyright 2014-2016 The MathWorks, Inc.

     
%  Copyright 2014-2016 The MathWorks, Inc.

    methods
        function out=SDRBuildArgsBase
        end

        function out=argIsEnabled(~) %#ok<STOUT>
        end

        function out=argIsVisible(~) %#ok<STOUT>
        end

        function out=assignDefaultArgValues(~) %#ok<STOUT>
        end

        function out=getArgEnables(~) %#ok<STOUT>
        end

        function out=getArgVisibilities(~) %#ok<STOUT>
        end

        function out=getPublicArgs(~) %#ok<STOUT>
        end

        function out=getThirdPartyRoot(~) %#ok<STOUT>
        end

        function out=ischar(~) %#ok<STOUT>
        end

        function out=parseSDRVersionFromHeaderFile(~) %#ok<STOUT>
        end

        function out=setHWInfoRegisters(~) %#ok<STOUT>
        end

        function out=validateArgValue(~) %#ok<STOUT>
        end

        function out=validateArgValues(~) %#ok<STOUT>
        end

        function out=validateFileExists(~) %#ok<STOUT>
        end

        function out=validateIPByte(~) %#ok<STOUT>
        end

        function out=validateMACByte(~) %#ok<STOUT>
        end

        function out=validateRange(~) %#ok<STOUT>
        end

    end
    methods (Abstract)
        % no default implementation
        getDefaultArgValue;

        getExtendedPropDataType;

    end
    properties
        BlackBoxFiles;

        ChannelMapping;

        DUTFiles;

        DUTName;

        FPGADevice;

        FPGAFamily;

        FPGAPackage;

        FPGASpeed;

        HWInfo;

        IPAddress;

        IsHDLWABuild;

        MACAddress;

        RFBoardRev;

        ToolName;

        UserLogicDatapath;

        UserLogicDatapathSet;

        UserLogicSynthFreq;

        VendorHDLSourceDir;

        allArgs;

        pluginName;

    end
end
