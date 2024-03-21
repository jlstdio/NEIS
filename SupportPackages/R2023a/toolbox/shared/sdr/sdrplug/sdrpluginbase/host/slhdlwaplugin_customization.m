function p = slhdlwaplugin_customization()

% Copyright 2014 The MathWorks, Inc.

    p.PluginName = 'Software Defined Radio';
    p.PluginObj  = sdrplugin.internal.hdlwa.SDRSLHDLWAPlugin.getInstance('reset');
end
