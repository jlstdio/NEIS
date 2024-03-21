classdef Logger < handle
  %Logger Message logger
  
  properties
    Caller = 'Unnamed'
    LogFileName = 'Untitled'
  end
  
  properties (Access = private)
    FID = -1
    LogToFile = true
  end
  
  methods
    function obj = Logger(caller)
      
      obj.Caller = caller;
      switch computer('arch')
        case 'win64'
          user = getenv('username');
          folder = tempdir;
        case 'glnxa64'
          [~,user] = system('whoami');
          folder = tempdir;
        case 'maci64'
          [~,user] = system('whoami');
          folder = getenv('TMPDIR');
      end

      obj.LogFileName = ...
        fullfile(folder, sprintf('mathworks_plutoradio_%s.log',strtrim(user)));
      
      if strcmp(getenv('RADIO_CONFIG_MANAGER_TEST'), 'TRUE')
        obj.LogToFile = false;
      end
    end
    
    function openLogFile(obj)
      obj.FID = fopen(obj.LogFileName,'a');
      if obj.FID == -1
        warning(message('plutoradio:Logger:CannotOpenLogFile', ...
          obj.LogFileName))
      end
      logMessage(obj, '-------------------------------------------------\n')
      logMessage(obj, sprintf('%s log: %s', obj.Caller, datetime))
    end
    
    function closeLogFile(obj)
      fclose(obj.FID);
      obj.FID = -1;
    end
    
    function logMessage(obj, msg)
      if obj.LogToFile
        if obj.FID ~= -1
          fprintf(obj.FID, msg);
        end
      else
        fprintf(msg);
      end
    end
  end
end

