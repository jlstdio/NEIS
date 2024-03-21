function plutoradiodemohelp
% PLUTORADIODEMOHELP  Load HTML write-up for current loaded demo model

% Copyright 2016-2017 The MathWorks, Inc.

% Find the full path of the model name
mdl = get_param(gcb, 'Parent');
plutoradiodoc(mdl)
