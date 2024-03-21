function plutoradioexamples
% PLUTORADIOEXAMPLES Open index of ADALM-PLUTO Radio examples

% Copyright 2017 The MathWorks, Inc.

sppkgNameTag = 'plutoradio';
myLocation = mfilename('fullpath');
docRoot = matlabshared.supportpkg.internal.getSppkgDocRoot(myLocation, sppkgNameTag);
if isempty(docRoot)
  error(message('hwconnectinstaller:setup:HelpMissing'));
end

featuredExamplesIndex = fullfile(docRoot, 'examples.html');

web(featuredExamplesIndex);

end
