function rootDir = getRootDir()
%getRootDir Return root directory

% Copyright 2017 The MathWorks, Inc.

% Get installation folder
rootDir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));

end
