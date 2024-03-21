classdef UpdateFirmware < matlab.hwmgr.internal.hwsetup.TemplateBase
  % UpdateFirmware - Screen implementation to enable users to update
  % firmware on the radio
  
  %   Copyright 2017-2022 The MathWorks, Inc.
  
  properties
    InfoText
    UpdateFirmwareButton
    StatusTable
    PlutoSDRDrive
    MessageBox
    WaitForEjectTimeout = 300
    UpdateFirmwareTimeout = 600
    FirmwareCompatible = false
  end
  
  methods
    function obj = UpdateFirmware(workflow)
      % Call to class constructor
      obj@matlab.hwmgr.internal.hwsetup.TemplateBase(workflow)
      
      if workflow.Testing == true
        obj.WaitForEjectTimeout = 10;
        obj.UpdateFirmwareTimeout = 15;
      end

      % Set Title
      obj.Title.Text = message('plutoradio:hwsetup:UpdateFirmware_Title').getString;
      
      % Set info text
      obj.InfoText = matlab.hwmgr.internal.hwsetup.Label.getInstance(obj.ContentPanel);
      obj.InfoText.Position = [20 280 400 90];
      obj.InfoText.Text = message('plutoradio:hwsetup:UpdateFirmware_InfoText', ...
        obj.Workflow.ExpectedFirmwareVersion).getString;
      obj.InfoText.Color = matlab.hwmgr.internal.hwsetup.util.Color.WHITE;

      % Set the Test Connection Button
      obj.UpdateFirmwareButton = matlab.hwmgr.internal.hwsetup.Button.getInstance(obj.ContentPanel);
      obj.UpdateFirmwareButton.Text = message('plutoradio:hwsetup:UpdateFirmware_UpdateButton').getString;
      obj.UpdateFirmwareButton.Color = matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
      obj.UpdateFirmwareButton.FontColor = matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
      obj.UpdateFirmwareButton.ButtonPushedFcn = @obj.updateFirmware;
      obj.UpdateFirmwareButton.Position = [20 240 143 22];

      % Set the StatusTable
      obj.StatusTable = matlab.hwmgr.internal.hwsetup.StatusTable.getInstance(obj.ContentPanel);
      obj.StatusTable.Steps = {...
        message('plutoradio:hwsetup:UpdateFirmware_StatusFindDrive').getString, ...
        message('plutoradio:hwsetup:UpdateFirmware_StatusCopyFirmware').getString, ...
        message('plutoradio:hwsetup:UpdateFirmware_StatusEject').getString, ...
        message('plutoradio:hwsetup:UpdateFirmware_StatusUpdate').getString, ...
        message('plutoradio:hwsetup:UpdateFirmware_StatusTest').getString};
      obj.StatusTable.Position = [20 100 420 130];
      obj.StatusTable.ColumnWidth = [30 400];
      
      if ismac
        % rearrange widgets for mac
        obj.StatusTable.ColumnWidth = [20 405];
      end
      
      % Set the HelpText
      obj.HelpText.WhatToConsider = [...
        message('plutoradio:hwsetup:UpdateFirmware_WhatToConsiderInfo').getString, ...
        '<br><br>', ...
        message('plutoradio:hwsetup:UpdateFirmware_WhatToConsiderFail').getString];
      obj.HelpText.AboutSelection = '';
      obj.HelpText.Additional = '';
      
      % Disable next button until the firmware update is successful
      obj.NextButton.Enable = 'off';

      initializeStatusTable(obj);
      
      show(obj);
      
      updateFirmware(obj)
    end
    
    function initializeStatusTable(obj)
      obj.StatusTable.Status = {...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question,...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question,...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question,...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question,...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question};
    end
    
    function out = getPreviousScreenID(obj)
      closeMessageBox(obj);
      out = 'plutoradio.internal.hwsetup.UnexpectedFirmware';
    end
    
    function out = getNextScreenID(obj)
      closeMessageBox(obj);
      out = 'plutoradio.internal.hwsetup.TestConnection';
    end
    
    function restoreScreen(obj)
      obj.enableScreen();
      if ~obj.FirmwareCompatible
        obj.NextButton.Enable = 'off';
        obj.UpdateFirmwareButton.Enable = 'on';
      else
        obj.UpdateFirmwareButton.Enable = 'off';
      end
    end
    
    function updateFirmware(obj, ~, ~)
      logMessage(obj, 'Starting firmware update');
      
      initializeStatusTable(obj);
      obj.NextButton.Enable = 'off';
      obj.BackButton.Enable = 'off';
      obj.CancelButton.Enable = 'off';
      obj.UpdateFirmwareButton.Enable = 'off';
      drawnow
      restoreOnCleanup = onCleanup(@obj.restoreScreen);
      forceTest = false;
      
      % Identify PlutoSDR drive
      logMessage(obj, 'Identifying radio drive');
      obj.StatusTable.Status{1} = ...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
      [status, msg] = identifyRadioDrive(obj);
      switch status
        case 0
          success = true;
        case {1,2}
          success = false;
          errordlg(obj.Workflow, ...
            message('plutoradio:hwsetup:UpdateFirmware_USBSearchFailed', msg).getString)
        case 3
          success = false;
          launchMessageBox(obj, ...
            message('plutoradio:hwsetup:UpdateFirmware_NotMounted').getString, ...
            'error');
      end
      if success == true
        obj.StatusTable.Status{1} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
      else
        obj.StatusTable.Status{1} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
      end
      
      if success
        % Copy firmware file
        logMessage(obj, 'Copying firmware file');
        obj.StatusTable.Status{2} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
        success = copyFirmwareFile(obj);
        if success == true
          obj.StatusTable.Status{2} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
        else
          obj.StatusTable.Status{2} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
        end
      end
      
      if success
        % Eject
        logMessage(obj, 'Waiting for eject');
        obj.StatusTable.Status{3} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
        success = checkEject(obj);
        if success == true
          obj.StatusTable.Status{3} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
        else
          obj.StatusTable.Status{3} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
          
          launchMessageBox(obj, ...
            message('plutoradio:hwsetup:UpdateFirmware_EjectFailedMsg').getString, ...
            'message');
        end
      end
      
      if success
        % Update
        logMessage(obj, 'Updating firmware');
        obj.StatusTable.Status{4} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
        success = checkUpdate(obj);
        if success == true
          obj.StatusTable.Status{4} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
        else
          obj.StatusTable.Status{4} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Warn;
        end
        forceTest = true;
      end
      
      % Test
      if success || forceTest
        logMessage(obj, 'Testing firmware version');
        obj.StatusTable.Status{5} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
        success = testFirmware(obj);
        if success
          obj.StatusTable.Status{5} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
          obj.FirmwareCompatible = true;
          logMessage(obj, 'Firmware updated successfully');
        else
          obj.StatusTable.Status{5} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
          logMessage(obj, 'Firmware update test failed');
        end
      end
      logMessage(obj, 'Finishing firmware update');
    end
  
    function success = copyFirmwareFile(obj)
      srcFile = fullfile(...
        matlab.internal.get3pInstallLocation('plutosdrfw.instrset'), ...
        'plutosdr-fw-v0.35.zip');
      [success, msg] = copyfile(obj.Workflow.HardwareInterface, ...
        srcFile, obj.PlutoSDRDrive);
      if ~success
        errordlg(obj.Workflow, msg);
      end
    end
    
    function success = checkEject(obj)
      success = false;
      
      switch computer('arch')
        case 'win64'
          fileBrowserName = 'File Explorer';
          extraInfo = message('plutoradio:hwsetup:UpdateFirmware_EjectMsgExtraWindows').getString;
        case 'maci64'
          fileBrowserName = 'Finder';
          extraInfo = '';
        case 'glnxa64'
          fileBrowserName = 'File Manager';
          extraInfo = '';
      end
      launchMessageBox(obj, ...
        message('plutoradio:hwsetup:UpdateFirmware_EjectMsg',fileBrowserName,extraInfo).getString, ...
        'message',fullfile(obj.Workflow.ResourceDir,'adalm-pluto_eject_icon.png'));
      
      timeout = obj.WaitForEjectTimeout;
      pollPeriod = 1;
      t = 0;
      while t < timeout
        if ~isRadioMounted(obj)
          success = true;
          break;
        end
        pause(pollPeriod)
        t = t + pollPeriod;
      end

      logMessage(obj, sprintf('Waited for %d seconds', t));
      
      closeMessageBox(obj)
    end
    
    function success = checkUpdate(obj)
      success = false;
      
      launchMessageBox(obj, ...
        message('plutoradio:hwsetup:UpdateFirmware_UpdateMsg').getString, ...
        'warning');

      timeout = obj.UpdateFirmwareTimeout;
      pollPeriod = 1;
      t = 0;
      while t < timeout
        if isRadioMounted(obj)
          success = true;
          break;
        end
        pause(pollPeriod)
        t = t + pollPeriod;
      end
      
      logMessage(obj, sprintf('Waited for %d seconds', t));

      closeMessageBox(obj);
    end
    
    function success = testFirmware(obj)
      success = isFirmwareCompatible(obj.Workflow);
    end
    
    function launchMessageBox(obj, msg, style, varargin)
      switch style
        case 'message'
          if nargin > 3
            iconPicture = varargin{1};
            obj.MessageBox = ...
              msgbox(msg, ...
              message('plutoradio:hwsetup:UpdateFirmware_Title').getString, ...
              'custom', imread(iconPicture));
          else
            obj.MessageBox = ...
              msgbox(msg, ...
              message('plutoradio:hwsetup:UpdateFirmware_Title').getString);
          end
        case 'warning'
          obj.MessageBox = warndlg(obj.Workflow, msg);
        case 'error'
          obj.MessageBox = errordlg(obj.Workflow, msg);
        otherwise
          obj.MessageBox = ...
            msgbox(msg, ...
            message('plutoradio:hwsetup:UpdateFirmware_Title').getString);
      end
    end
    
    function closeMessageBox(obj)
      if ishandle(obj.MessageBox)
        if isvalid(obj.MessageBox)
          close(obj.MessageBox)
        end
      end
    end
    
    function delete(obj)
      closeMessageBox(obj);
    end
  end
  
  methods (Access = private)
    function mounted = isRadioMounted(obj)
      status = identifyRadioDrive(obj);
      mounted = (status == 0);
    end
    
    function [status, msg] = identifyRadioDrive(obj)
      %identifyRadioDrive Identify PlutoSDR mass storage device drive
      %   STATUS = identifyRadioDrive(RI) identifies the PlutoSDR mass
      %   storage device drive. The result is stored in PlutoSDRDrive
      %   property. STATUS can be the following:
      %   0: Success
      %   1: Cannot determine drive
      %   2: Drive does not contain expected files
      %   3: Mount command failed. Radio is there but not mounted.
      
      plutoSDRDrive = '';
      msg = '';

      switch computer('arch')
        case 'win64'
          [flag,out]=getLogicalDiskList(obj.Workflow.HardwareInterface);
          if flag
            status = 1;
            msg = out;
            return
          end
          driveData=textscan(out, '%s %s');

          % At this point we know that there is only one radio. Search for
          % that one.
          status = 1;
          for p=1:size(driveData{2},1)
            if strcmp(driveData{2}{p}, 'PlutoSDR')
              plutoSDRDrive = driveData{1}{p};
              status = 0;
              break;
            end
          end
          if status ~= 0
            return;
          end
        case 'maci64'
          [~, allPlutoSDRDrives] =  getLogicalDiskList(obj.Workflow.HardwareInterface);
          if ~isempty(allPlutoSDRDrives)
            status = 0;
            plutoSDRDrive = ['/Volumes/' allPlutoSDRDrives(1).name];
          else
            status = 1;
            return
          end
        case 'glnxa64'
          [status,out]=getLogicalDiskList(obj.Workflow.HardwareInterface);
          if status == 0
            idx=strfind(out, sprintf('%s-0:0 -> ../../', getSerialNum(obj.Workflow)));
            if ~isempty(idx)
              startIdx = idx + 14 + length(getSerialNum(obj.Workflow));
              endIdx = strfind(out(idx:end), newline);
              dev = sprintf('/dev/%s', out(startIdx:endIdx(1)+idx-2));
            else
              status = 1;
              msg = out;
              return
            end
          else
            status = 1;
            msg = out;
            return
          end
          
          [status,out] = mount(obj.Workflow.HardwareInterface, dev);
          if status == 0
            if ~isempty(out)
              out = textscan(out, '%s');
              plutoSDRDrive = out{1}{3};
            end
          else
            status = 3;
            return;
          end
      end
      
      logMessage(obj, sprintf('Found PlutoSDR drive %s', plutoSDRDrive));
      
      if checkPlutoSDRDrive(obj, plutoSDRDrive) == false
        status = 2;
      end
    end
    
    function success = checkPlutoSDRDrive(obj, plutoSDRDrive)
      success = false;
      if exist(obj.Workflow.HardwareInterface, plutoSDRDrive)
        contents = dir(obj.Workflow.HardwareInterface, plutoSDRDrive);
        % Contents should have img dir and info.html file
        foundImgDir = false;
        foundInfoHtml = false;
        for p=1:length(contents)
          if contents(p).isdir
            if strcmp(contents(p).name, 'img')
              foundImgDir = true;
            end
          else
            if strcmp(contents(p).name, 'info.html')
              foundInfoHtml = true;
            end
          end
        end
        if foundImgDir && foundInfoHtml
          success = true;
          obj.PlutoSDRDrive = plutoSDRDrive;
        end
      end
    end    
  end
end
