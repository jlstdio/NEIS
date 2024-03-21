classdef HardwareInterface < handle

%   Copyright 2017-2018 The MathWorks, Inc.

  properties 
    RadioID
    SerialNum
  end

  properties (Access = private)
    WarningState
  end

  methods
    function radios = getConnectedRadios(obj) %#ok<MANU>
      radios = findPlutoRadio;
    end
    
    function [expVer,curVer] = getFirmwareVersion(obj)
      suppressFirmwareVersionWarning(obj);
      restoreWarning = onCleanup(@()restoreFirmwareVersionWarning(obj));
      
      rx = sdrrx('Pluto', 'RadioID', obj.RadioID);
      radioInfo = info(rx);
      if strcmp(radioInfo.Status, 'Full information')
          expVer = radioInfo.ExpectedFirmwareVersion;
          curVer = radioInfo.RadioFirmwareVersion;
        else
          expVer = "";
          curVer = "";
      end
    end
    
    function busy = isRadioBusy(obj, radioID)
      suppressFirmwareVersionWarning(obj);
      restoreWarning = onCleanup(@()restoreFirmwareVersionWarning(obj));

      rx = sdrrx('Pluto', 'RadioID', radioID);
      radioInfo = info(rx);
      if strcmp(radioInfo.Status, 'Busy')
        busy = true;
      else
        busy = false;
      end
    end
    
    function [status, msg] = run(obj, command, varargin) %#ok<INUSL>
      [status, msg] = system(command, varargin{:});
    end
    
    function out = dir(obj, folder) %#ok<INUSL>
      out = dir(folder);
    end
    
    function [status, out] = getLogicalDiskList(obj) %#ok<MANU>
      switch computer('arch')
        case 'win64'
          [status,out]=system('wmic logicaldisk get deviceid, volumename');
        case 'maci64'
          out = dir('/Volumes/PlutoSDR*');
          status = 0;
        case 'glnxa64'
          [status,out]=system('ls -l /dev/disk/by-id/');
      end
    end
    
    function [status,out] = mount(obj, dev) %#ok<INUSL>
      [status, out] = system(sprintf('mount | grep ''%s''', dev));
    end
    
    function success = exist(obj, folder) %#ok<INUSL>
      success = exist(folder, 'dir');
    end
    
    function [success, msg] = copyfile(obj, srcFile, dstFolder) %#ok<INUSL>
      [success, msg] = copyfile(srcFile, dstFolder, 'f');
    end
    
    function suppressFirmwareVersionWarning(obj)
      obj.WarningState = warning('off', ...
        'plutoradio:sysobj:FirmwareIncompatible');
    end
    
    function restoreFirmwareVersionWarning(obj)
      warning(obj.WarningState);
    end

  end
end
