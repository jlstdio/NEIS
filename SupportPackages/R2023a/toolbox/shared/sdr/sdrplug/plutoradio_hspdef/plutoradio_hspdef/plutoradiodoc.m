function plutoradiodoc(topic)
% PLUTORADIODOC ADALM-PLUTO Radio function to open doc.
%
% PLUTORADIODOC  Open top-level ADALM-PLUTO Radio documentation.
%
% PLUTORADIODOC(topic) Open specific topic in documentation.  
% 

% Copyright 2016-2017 The MathWorks, Inc.

if (nargin == 0)
    topic = 'sdrpluto_doccenter';
end

sppkgNameTag = 'plutoradio';
myLocation = mfilename('fullpath');
docRoot = matlabshared.supportpkg.internal.getSppkgDocRoot(myLocation, sppkgNameTag);
if isempty(docRoot)
    error(message('hwconnectinstaller:setup:HelpMissing'));
end

helpview(fullfile(docRoot,'helptargets.map'), topic);
