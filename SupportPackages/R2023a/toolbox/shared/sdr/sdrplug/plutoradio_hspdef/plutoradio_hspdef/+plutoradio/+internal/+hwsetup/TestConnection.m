classdef TestConnection < matlab.hwmgr.internal.hwsetup.VerifyHardwareSetup
  % TestConnection - Screen implementation to confirm that PlutoSDR can
  % transmit and receive.
  
  %   Copyright 2017-2018 The MathWorks, Inc.
  
  properties
    RadioID
  end
  
  methods
    function obj = TestConnection(workflow)
      % Call to class constructor
      obj@matlab.hwmgr.internal.hwsetup.VerifyHardwareSetup(workflow)
      
      % Set Title
      obj.Title.Text = message('plutoradio:hwsetup:TestConnection_Title').getString;
      
      % Set the Test Connection Button
      obj.TestConnButton.Text = message('plutoradio:hwsetup:TestConnection_Test').getString;
      obj.TestConnButton.ButtonPushedFcn = @obj.testConnection;
      obj.TestConnButton.Position = [20 350 143 22];

      % Set the StatusTable
      obj.StatusTable.Steps = {...
        message('plutoradio:hwsetup:TestConnection_StatusConnect').getString, ...
        message('plutoradio:hwsetup:TestConnection_StatusTestTx').getString, ...
        message('plutoradio:hwsetup:TestConnection_StatusTestRx').getString};
      obj.StatusTable.Position = [20 260 420 80];
      obj.StatusTable.ColumnWidth = [30 400];
      
      % Set the DeviceInfoTable
      obj.DeviceInfoTable.Labels = {...
        message('plutoradio:hwsetup:TestConnection_RadioName').getString,...
        message('plutoradio:hwsetup:TestConnection_RadioAddress').getString,...
        message('plutoradio:hwsetup:TestConnection_SerialNumber').getString};
      obj.DeviceInfoTable.ColumnWidth = 250;
      obj.DeviceInfoTable.Position = [20 150 420 80];
      
      if ismac
        % rearrange widgets for mac
        obj.StatusTable.ColumnWidth = [20 405];
        obj.DeviceInfoTable.ColumnWidth = 325;
      end
      % Set the HelpText
      obj.HelpText.WhatToConsider = [...
        message('plutoradio:hwsetup:TestConnection_WhatToConsider1').getString, ...
        '<br><br>', ...
        message('plutoradio:hwsetup:TestConnection_WhatToConsider2').getString];
      obj.HelpText.AboutSelection = '';
      obj.HelpText.Additional = ['<br><br>',...
        message('plutoradio:hwsetup:TestConnection_ConfigFail').getString];
      
      reinit(obj)
    end
    
    function reinit(obj)
      obj.DeviceInfoTable.Values = ...
        {'','',''};
      obj.StatusTable.Status = {...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question,...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question,...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Question};
    end
    
    function out = getPreviousScreenID(obj) %#ok<*MANU>
      if obj.Workflow.UpdateFirmwareWorkflow
        if obj.Workflow.UpdateFirmwareSelected
          out = 'plutoradio.internal.hwsetup.UpdateFirmware';
        else
          out = 'plutoradio.internal.hwsetup.UnexpectedFirmware';
        end
      else
        out = 'plutoradio.internal.hwsetup.ConnectHardware';
      end
    end
    
    function out = getNextScreenID(obj)
      out = 'plutoradio.internal.hwsetup.SetupComplete';
    end
    
    function restoreScreen(obj)
      obj.enableScreen();
    end
    
    function testConnection(obj, ~, ~)
        % Clear the Icon before disabling the screen
        obj.StatusTable.Status = {...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Question, ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Question, ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Question, ...
          };
        obj.NextButton.Enable = 'off';
        obj.BackButton.Enable = 'off';
        drawnow
        restoreOnCleanup = onCleanup(@obj.restoreScreen);
        
      % Search for radio
      obj.StatusTable.Status{1} = ...
        matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
      success = getRadioInfo(obj);
      if success == true
        obj.StatusTable.Status{1} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
      else
        obj.StatusTable.Status{1} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
      end
      
      if success
        % Test transmitter
        obj.StatusTable.Status{2} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
        success = testTransmitter(obj);
        if success == true
          obj.StatusTable.Status{2} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
        else
          obj.StatusTable.Status{2} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
        end
        
        % Test receiver
        obj.StatusTable.Status{3} = ...
          matlab.hwmgr.internal.hwsetup.StatusIcon.Busy;
        success = testReceiver(obj);
        if success == true
          obj.StatusTable.Status{3} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Pass;
        else
          obj.StatusTable.Status{3} = ...
            matlab.hwmgr.internal.hwsetup.StatusIcon.Fail;
        end
      end
    end
    
    function success = testTransmitter(obj)
      try
        fc = 2.4e9;
        fs = 600e3;
        spf = 10000;
        txFreq = 10000;
        
        tx = sdrtx('Pluto', ...
          'RadioID', obj.RadioID, ...
          'CenterFrequency', fc, ...
          'BasebandSampleRate', fs);
        tx.Gain = 0;
        
        src = dsp.SineWave('Frequency', txFreq, ...
          'Amplitude', 0.5, ...
          'ComplexOutput', true, ...
          'Method', 'Table lookup', ...
          'SampleRate', fs, ...
          'SamplesPerFrame', spf);
        
        success = true;
        try
          x = src(); %#ok<NASGU> x used in evalc
          evalc('tx(x)');
          for p=1:100
            x = src(); %#ok<NASGU> x used in evalc
            evalc('tx(x)');
          end
        catch
          success = false;
        end
        release(src);
        release(tx);
      catch
        success = false;
      end
    end
    
    function success = testReceiver(obj)
      try
        fc = 2.4e9;
        fs = 600e3;
        spf = 10000;
        txFreq = 10000;
        
        rx = sdrrx('Pluto', ...
          'RadioID', obj.RadioID, ...
          'CenterFrequency', fc, ...
          'SamplesPerFrame', spf, ...
          'BasebandSampleRate', fs);
        rx.GainSource = 'Manual';
        rx.Gain = 50;
        tx = sdrtx('Pluto', ...
          'RadioID', obj.RadioID, ...
          'CenterFrequency', fc, ...
          'BasebandSampleRate', fs);
        tx.Gain = 0;
        
        src = dsp.SineWave('Frequency', txFreq, ...
          'Amplitude', 0.5, ...
          'ComplexOutput', true, ...
          'Method', 'Table lookup', ...
          'SampleRate', fs, ...
          'SamplesPerFrame', spf);
        
        overrun = false;
        x = src(); %#ok<NASGU> x used in evalc
        evalc('tx.transmitRepeat(x)');
        for p=1:100
          len = 0;
          
          while len <= 0
            [~,r,len,over] = evalc('rx()');
          end
          if over
            overrun = true;
          end
        end
        
        spectrum = abs(fft(r));
        f=linspace(-fs/2,fs/2,10000);
        [~,idx] = findpeaks(fftshift(spectrum), 'MinPeakProminence', max(spectrum)/2);
        rcvFreq = f(idx);
        
        release(rx)
        release(tx)
        release(src)
        
        if (rcvFreq - txFreq) / txFreq < 1e-2
          toneFound = true;
        else
          toneFound = false;
        end
        
        success = toneFound && ~overrun;
      catch
        success = false;
      end
    end
    
    function success = getRadioInfo(obj)
      % Try at most about 15 sec
      for cnt=1:10
        pause(1)
        % Check if the driver is installed
        try
          radioInfo = findPlutoRadio();
        catch
          radioInfo = {};
        end
        numRadios = length(radioInfo);
        if numRadios < 1
          success = false;
        else
          success = true;
        end
        
        if success
          break
        end
      end
      
      radioPlatform = 'ADALM-PLUTO';
      if success
        obj.RadioID = radioInfo(1).RadioID;
        obj.DeviceInfoTable.Values = ...
          {radioPlatform,radioInfo(1).RadioID,radioInfo(1).SerialNum};
      else
        obj.RadioID = '';
        obj.DeviceInfoTable.Values = ...
          {radioPlatform,'Not found','Not found'};
      end
    end
  end
end
