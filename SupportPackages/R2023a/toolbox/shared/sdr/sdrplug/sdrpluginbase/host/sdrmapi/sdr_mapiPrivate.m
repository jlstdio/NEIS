function varargout = sdr_mapiPrivate(cmd, varargin)
%#codegen
%
% This function unifies handling of interp vs. codegen call as well as
% errStat / errStr assignment.
%

%   Copyright 2011-2017 The MathWorks, Inc.

% 
% ++++ FIXME: Temporary removal of enum usage ++++
SDRPluginStatusT_SDRDriverError = int32(0); % Replacing SDRPluginStatusT.SDRDriverError
SDRPluginStatusT_SDRDriverSuccess = int32(1); % Replacing SDRPluginStatusT.SDRDriverSuccess



% THESE SIZES MUST MATCH THOSE VALUES IN THE C-CODE!
MAX_STR_SIZE                = 1024;
MAX_ERROR_MESSAGE_LENGTH    = 1024;
MAX_DATA_SIZE               = 1024*300; % FIXME: make variable
MAX_CONFIG_SIZE             = 1024*5;   % FIXME: make variable

% function is being called in interpreted mode
if (isempty(coder.target()))
    errId  = '';
    errStr = '';
    
    cmd_m = ['sdr_' cmd];

    switch (cmd)
    
        % SPECIAL CASE: setupImpl.
        case {'setupImpl'}
            [varargout{1}, errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});
            % Lock the mex file if called from MATLAB. This is not called for
            % generated code. Locking the mex file in MATLAB prevents MATLAB
            % from hanging if clear all is called. Clear all first deletes mex
            % files. That removes the driver and hangs MATLAB if a driver is in
            % use, i.e. System object is locked. Lock only if successful.
            if errStat == SDRPluginStatusT_SDRDriverSuccess
                sdrmapi('sdr_mexLock');
            end

        % SPECIAL: releaseImpl
        case {'releaseImpl'}
            [errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});
            % Unlock the mex file if called from MATLAB. This is not called for
            % generated code. See "setupImpl" case above.
            if errStat == SDRPluginStatusT_SDRDriverSuccess
                sdrmapi('sdr_mexUnlock');
            end

        % 0 in, 1 out
        case 'reportDrivers'
            [retStr, errStat, errId, errStr] = sdrmapi(cmd_m);
            retStr = l_int8ArrayToString(retStr);
            varargout{1} = retStr;

        % >0 in, 0 out
        case {'deleteDriver', 'reset', 'setConfiguration','processTunedPropertiesImpl', ...
                'writeAddress','testCheckPattern','testGeneratePattern','setProperty'}
            [errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});
        
        % >0 in, 1 out
        case {'findRadios','createDriver','infoImpl'}
            [varargout{1}, errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});


        % >0 in, 2 out
        case {'getConfiguration','readAddress','testLoopback', 'getProperty'}
            [varargout{1}, varargout{2}, errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});

        % >0 in, 5 out
        case {'txStepImpl','txStepImplInt16','txStepImplSingle','txStepImplDouble' }
            [varargout{1}, varargout{2}, ...
             errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});
            
        % >0 in, 7 out
        case 'rxStepImpl'
            [varargout{1}, varargout{2}, varargout{3}, varargout{4}, ...
             errStat, errId, errStr] = sdrmapi(cmd_m, varargin{:});

    end
    
    % the mex returns a uint8 array of 1024...Convert to real string.
    errId  = l_int8ArrayToString(errId);
    errStr = l_int8ArrayToString(errStr);
    
% function is being called in codegen mode
else
    
    % FIXME: Test that removing this is okay.  Believe issue was on Windows
    % where device is unplugged in middle of stream.
    % We really want to avoid this as it makes debug much more difficult.
    % coder.ceval('mexLock');

    coder.cinclude('sdrcapi.h'); % FIXME: Explicitly include header file 
    errStat_i = SDRPluginStatusT_SDRDriverError;
    errId     = char(zeros(1,MAX_STR_SIZE));
    errStr    = char(zeros(1,MAX_ERROR_MESSAGE_LENGTH));

    
    cmd_c = [cmd '_c'];
    
    switch (cmd)
        % SPECIAL: this is code not defined in our lib, but rather right here.
        % See 'setupImpl' and 'releaseImpl' in the non-codegen section above.
        case {'sdr_mexLock'}
            coder.ceval('mexLock');
            errStat_i = SDRPluginStatusT_SDRDriverSuccess;
      
        case {'sdr_mexUnlock'}
            coder.ceval('mexUnlock');
            errStat_i = SDRPluginStatusT_SDRDriverSuccess;

        case 'findRadios'
            flatAddrList     = char(zeros(1,MAX_STR_SIZE));
            coder.ceval(cmd_c, varargin{1}, varargin{2}, ...
                        coder.ref(flatAddrList), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1}     = flatAddrList;

        case 'reportDrivers'
            flatAddrList     = char(zeros(1,MAX_STR_SIZE));
            coder.ceval(cmd_c, coder.ref(flatAddrList), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1}     = flatAddrList;
 
        case {'deleteDriver', 'reset', 'releaseImpl'}
            coder.ceval(cmd_c, varargin{:}, ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));

        case 'createDriver'
            cfg = varargin{2};
            driverHandle = int32(0);
            coder.ceval(cmd_c, varargin{1}, coder.rref(cfg), ...
                        coder.wref(driverHandle), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = driverHandle;

        case {'setConfiguration','processTunedPropertiesImpl'}
            cfg = varargin{3};
            coder.ceval(cmd_c, varargin{1}, varargin{2}, coder.rref(cfg), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
                    
        case 'getConfiguration'
            whatCfg     = varargin{3};
            retCfgSize  = int32(0);
            retCfg      = zeros(MAX_CONFIG_SIZE,1,'uint8');
            coder.ceval(cmd_c, varargin{1}, varargin{2}, coder.rref(whatCfg), ...
                        coder.ref(retCfgSize), coder.ref(retCfg), ...                        
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = retCfgSize;
            varargout{2} = retCfg;

        case {'writeAddress'}
            data = varargin{6};
            coder.ceval(cmd_c, varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, coder.rref(data), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
           
        case {'readAddress'}
            rdata = zeros(varargin{5}*varargin{3},1,'uint8');
            rdwlen = varargin{5};
            coder.ceval(cmd_c, varargin{1}, varargin{2}, varargin{3}, varargin{4}, coder.ref(rdwlen), coder.ref(rdata), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = rdata;
            varargout{2} = rdwlen;
            
         case {'testCheckPattern','testGeneratePattern'}
            coder.ceval(cmd_c, varargin{1}, varargin{2}, varargin{3}, ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
           
         case {'testLoopback'}
            data = varargin{3};
            rdata = zeros(varargin{2},1,'uint8');
            rdwlen = varargin{2};
            coder.ceval(cmd_c, varargin{1}, varargin{2}, coder.rref(data), coder.ref(rdwlen), coder.ref(rdata), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = rdata;
            varargout{2} = rdwlen;
            
        case {'setProperty'}
            data = varargin{4};
            coder.ceval(cmd_c, varargin{1}, varargin{2}, varargin{3}, coder.rref(data), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            
        case {'getProperty'}
            rdata = zeros(MAX_CONFIG_SIZE,1,'uint8');
            rdwlen = uint32(MAX_CONFIG_SIZE);
            coder.ceval(cmd_c, varargin{1}, varargin{2}, coder.ref(rdwlen), coder.ref(rdata), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = rdata;
            varargout{2} = rdwlen;
                  
        case 'setupImpl'
            creationArgs    = varargin{2};
            nontunableProps = varargin{4};
            tunableProps    = varargin{6};
            driverHandle = int32(0);
            coder.ceval(cmd_c, ...
                        varargin{1}, coder.rref(creationArgs), ...
                        varargin{3}, coder.rref(nontunableProps), ...
                        varargin{5}, coder.rref(tunableProps), ...
                        coder.wref(driverHandle), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = driverHandle;

        case 'rxStepImpl'
            dataSize        = int32(0);
            data            = zeros(varargin{2},1,'uint8');
            metaDataSize    = int32(0);
            metaData        = zeros(MAX_CONFIG_SIZE,1,'uint8');
            coder.ceval(cmd_c, ...
                varargin{1}, ...
                coder.wref(dataSize), coder.ref(data), ...
                coder.wref(metaDataSize), coder.wref(metaData), ...
                coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = dataSize;
            varargout{2} = data;
            varargout{3} = metaDataSize;
            varargout{4} = metaData;
            
        case 'txStepImpl'
            data = varargin{3};
            metaDataSize    = int32(0);
            metaData        = zeros(MAX_CONFIG_SIZE,1,'uint8');
            coder.ceval(cmd_c, ...
                varargin{1}, ...
                varargin{2}, coder.rref(data), ...
                coder.wref(metaDataSize), coder.wref(metaData), ...
                coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = metaDataSize;
            varargout{2} = metaData;

        case {'txStepImplInt16','txStepImplSingle','txStepImplDouble'}
            data = varargin{3};
            metaDataSize    = int32(0);
            metaData        = zeros(MAX_CONFIG_SIZE,1,'uint8');
            coder.ceval('txStepImplVoid_c', ...
                varargin{1}, ...
                varargin{2}, coder.rref(data), ...
                coder.wref(metaDataSize), coder.wref(metaData), ...
                coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1} = metaDataSize;
            varargout{2} = metaData;

        case 'infoImpl'
            infoStr     = char(zeros(1,MAX_STR_SIZE));
            coder.ceval(cmd_c, varargin{1}, coder.ref(infoStr), ...
                        coder.wref(errStat_i), coder.ref(errId), coder.ref(errStr));
            varargout{1}     = infoStr;

    end

    errStat     = errStat_i;

end

switch (cmd)
    case {'deleteDriver', 'reset', 'setConfiguration', 'releaseImpl','processTunedPropertiesImpl', ...
            'writeAddress','testCheckPattern','testGeneratePattern', 'setProperty'} 
        varargout{1} = errStat;
        varargout{2} = errId;
        varargout{3} = errStr;

    case {'findRadios', 'reportDrivers','createDriver','setupImpl','infoImpl'}
        varargout{2} = errStat;
        varargout{3} = errId;
        varargout{4} = errStr;
        
    case {'getConfiguration','txStepImpl','txStepImplInt16','txStepImplSingle','txStepImplDouble', ...
            'readAddress','testLoopback', 'getProperty'}
        varargout{3} = errStat;
        varargout{4} = errId;
        varargout{5} = errStr;

    case 'rxStepImpl'
        varargout{5} = errStat;
        varargout{6} = errId;
        varargout{7} = errStr;
end
end

function outarg = l_int8ArrayToString(inarg)
    firstNull = find(inarg==0,1);
    if (firstNull <= 1)
        outarg = '';
    else
        outarg = sprintf('%s', inarg(1:firstNull-1));
    end
end
