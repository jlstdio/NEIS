function [mapName, pathToMap, found] = getBlockHelpMapNameAndPath(block_type)
%  Returns the mapName and the relative path to the maps file for this block_type

% This file was based on toolbox/dsp/dsp/getBlockHelpMapNameAndPath and
% sdrfdoc.

% Internal note: 
%   First column is the "System object name", corresponding to the block, 
%   Second column is the anchor ID, the doc uses for the block.
%   For core blocks, the first column is the 'BlockType'.

% Copyright 2016-2017 The MathWorks, Inc.
    
blks = {...
    'comm.SDRRxPluto', 'comminternalsdrrxplutosl';...
    'comm.SDRTxPluto', 'comminternalsdrtxplutosl';...
    };

[mapName, pathToMap, found] = plutoblkHelpMapName(block_type, blks);

function [mapName, pathToMap, found] = plutoblkHelpMapName(block_type, blks)
docroot = matlabshared.supportpkg.internal.getSppkgDocRoot(mfilename('fullpath'),'plutoradio');
pathToMap = fullfile(docroot,'helptargets.map');
found = false;
i = strmatch(block_type, blks(:,1),'exact');
if isempty(i)
    mapName = 'User Defined';
else
    found = 'fullpath';
    mapName = blks(i,2);
end
