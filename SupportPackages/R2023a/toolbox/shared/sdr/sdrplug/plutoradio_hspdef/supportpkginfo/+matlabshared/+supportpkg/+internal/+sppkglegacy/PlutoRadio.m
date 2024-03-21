classdef PlutoRadio < matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase
    % This class is used by support package infrastructure to find the legacy support_package_registry.xml
    % for the BaseCode specified below. See the base class for more information.
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Constant)
        BaseCode = 'PLUTO';
    end
    methods (Access = public)
        function registryDir = getRegistryFileDir(~)
            % This method should return the location of the
            % support_package_registry.xml file
            componentBaseDir = fileparts(fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))))));
            registryDir = fullfile(componentBaseDir, 'registry');
        end
    end
end
