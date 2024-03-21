classdef ExternalDependency< coder.ExternalDependency
% matlabshared.libiio.ExternalDependency Helper Class for libIIO support
%
% This abstract system object defines the APIs necessary to use libIIO
% for MATLAB/Simulink simulation as well as codegen on a Linux target

     
    % Copyright 2016-2018 The MathWorks, Inc.

    methods
        function out=ExternalDependency
        end

        function out=getDescriptiveName(~) %#ok<STOUT>
            % getDescriptiveName get the name of the block
            % Internal function for Simulink Block generation
        end

        function out=isSupportedContext(~) %#ok<STOUT>
            % isSupportedContext Check if context is supported
            %
            % Determine if build context supports external dependency
        end

        function out=updateBuildInfo(~) %#ok<STOUT>
            % updateBuildInfo update the build for code generation
            %
            % Add required source, include and linker files to the build
        end

    end
end
