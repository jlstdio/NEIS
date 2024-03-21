classdef UnexpectedFirmware < matlab.hwmgr.internal.hwsetup.TemplateBase
  % UnexpectedFirmware - Screen implementation to let users opt-out of
  % firmware update
  
  %   Copyright 2018 The MathWorks, Inc.
  
  properties
    InfoText
    UpdateFirmwareCheckbox
  end
  
  methods
    function obj = UnexpectedFirmware(workflow)
      % Call to class constructor
      obj@matlab.hwmgr.internal.hwsetup.TemplateBase(workflow)

      % Set Title
      obj.Title.Text = message('plutoradio:hwsetup:UnexpectedFirmware_Title').getString;
      
      % Set info text
      obj.InfoText = matlab.hwmgr.internal.hwsetup.Label.getInstance(obj.ContentPanel);
      obj.InfoText.Position = [20 230 400 150];
      obj.InfoText.Text = message('plutoradio:hwsetup:UnexpectedFirmware_InfoText', ...
        getSerialNum(obj.Workflow), ...
        obj.Workflow.CurrentFirmwareVersion, ...
        obj.Workflow.ExpectedFirmwareVersion).getString;
      obj.InfoText.Color = matlab.hwmgr.internal.hwsetup.util.Color.WHITE;

      % Set the update firmware checkbox
      obj.UpdateFirmwareCheckbox = matlab.hwmgr.internal.hwsetup.CheckBox.getInstance(obj.ContentPanel);
      obj.UpdateFirmwareCheckbox.Text = message('plutoradio:hwsetup:UnexpectedFirmware_UpdateCheckbox').getString;
      obj.UpdateFirmwareCheckbox.ValueChangedFcn = @obj.checkboxValueChanged;
      obj.UpdateFirmwareCheckbox.Value = true;
      obj.UpdateFirmwareCheckbox.Position = [20 200 400 22];

      % Set the HelpText
      obj.HelpText.WhatToConsider = [...
        message('plutoradio:hwsetup:UnexpectedFirmware_WhatToConsiderInfo', ...
        obj.Workflow.ExpectedFirmwareVersion).getString, ...
        '<br><br>', ...
        message('plutoradio:hwsetup:UnexpectedFirmware_WhatToConsiderRevert', ...
        obj.Workflow.CurrentFirmwareVersion).getString];
      obj.HelpText.AboutSelection = '';
      obj.HelpText.Additional = '';
    end
    
    function reinit(obj)
      obj.InfoText.Text = message('plutoradio:hwsetup:UnexpectedFirmware_InfoText', ...
        getSerialNum(obj.Workflow), ...
        obj.Workflow.CurrentFirmwareVersion, ...
        obj.Workflow.ExpectedFirmwareVersion).getString;
    end
    
    function out = getPreviousScreenID(obj) %#ok<MANU>
      out = 'plutoradio.internal.hwsetup.ConnectHardware';
    end
    
    function out = getNextScreenID(obj)
      logMessage(obj, ...
        sprintf('UpdateFirmwareSelected = %d', ...
        obj.Workflow.UpdateFirmwareSelected));

      if obj.Workflow.UpdateFirmwareSelected == true
        out = 'plutoradio.internal.hwsetup.UpdateFirmware';
      else
        out = 'plutoradio.internal.hwsetup.TestConnection';
      end
    end
    
    function checkboxValueChanged(obj, src, ~)
      if src.Value == true
        obj.Workflow.UpdateFirmwareSelected = true;
      else
        obj.Workflow.UpdateFirmwareSelected = false;
      end
    end
  end
end
