classdef InstallDriverWindows < plutoradio.internal.hwsetup.InstallDriver

%   Copyright 2017 The MathWorks, Inc.

  methods
    function obj = InstallDriverWindows(varargin)
      obj@plutoradio.internal.hwsetup.InstallDriver(varargin{:});
      
      obj.Title.Text = message('plutoradio:hwsetup:InstallDriverWindows_Title').getString;
      
      obj.InfoText1.Position = [20 340 400 40];
      obj.InfoText1.Text = message('plutoradio:hwsetup:InstallDriverWindows_InfoText1').getString;

      obj.InfoText2.Position = [20 310 400 20];
      obj.InfoText2.Text = message('plutoradio:hwsetup:InstallDriverWindows_InfoText2').getString;
      
      obj.HelpText.AboutSelection = '';
      obj.HelpText.WhatToConsider = message('plutoradio:hwsetup:InstallDriverWindows_WhatToConsider').getString;
    end
    
    function out = getNextScreenID(obj)
      % HSA infrastructure requires a "getNextScreenID" method implemented
      % in the leaf class. Otherwise, it renders "Finish" button instead of
      % "Next".
      out = getNextScreenIDImpl(obj);
    end
  end
  
  methods (Access = protected)
    function [status,msg] = installDriverImpl(obj)
      
      downloadFolder = matlab.internal.get3pInstallLocation('plutousbdriver.instrset');

      % Find the installer executable
      installer = fullfile(downloadFolder, ...
        'plutowinusb', 'PlutoSDR-M2k-USB-Drivers.exe');
      
      command = sprintf(['start "plutowinusb" /B /W ' ...
        '%s /SP- /VERYSILENT ' ...
        '/SUPRESSMSGBOXES /DPINSTFLAGS="/SW /F"'], installer); 
      [status,msg] = run(obj.Workflow.HardwareInterface, command);
    end
  end
end