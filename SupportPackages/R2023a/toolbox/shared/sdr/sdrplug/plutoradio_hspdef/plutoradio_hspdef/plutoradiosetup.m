function plutoradiosetup
%PLUTORADIOSETUP Finish callback for support package installation.
%
% This is a private function.
%
%   Copyright 2016-2018 The MathWorks, Inc.

% we have just done an installation.  refresh the list of registered plugins.
sdrplugin.internal.SDRPluginManager.getInstance('reset');

fprintf( [ ...
'For more help, use <a href="matlab:help plutoradio">help plutoradio</a>,', ...
' or see the <a href="matlab:plutoradiodoc">', ...
'full documentation</a>.\n\n' ...
]);
end
