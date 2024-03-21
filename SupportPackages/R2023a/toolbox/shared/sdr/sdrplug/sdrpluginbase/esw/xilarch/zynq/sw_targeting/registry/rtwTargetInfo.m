function rtwTargetInfo(tr)
%CUSTOMIZATIONXILINXSDRZ Register XILINX SDRZ

% Copyright 2019 The MathWorks, Inc.


tr.registerTargetInfo(@loc_createPILConfig);
codertarget.TargetRegistry.addToTargetRegistry(@loc_registerThisTarget);
codertarget.TargetBoardRegistry.addToTargetBoardRegistry(@loc_registerBoardsForThisTarget);
end
% -------------------------------------------------------------------------
function ret = loc_registerThisTarget()
ret.Name = 'XILINX SDRZ';
[targetFilePath, ~, ~] = fileparts(mfilename('fullpath'));
targetFilePath = fullfile(targetFilePath, '..');
ret.TargetFolder = targetFilePath;
ret.ReferenceTargets = {'ARM Cortex-A Base'};
end
% -------------------------------------------------------------------------
function boardInfo = loc_registerBoardsForThisTarget()
target = 'XILINX SDRZ';
[targetFolder, ~, ~] = fileparts(mfilename('fullpath'));
targetFolder = fullfile(targetFolder, '..');
boardFolder = codertarget.target.getTargetHardwareRegistryFolder(targetFolder);
boardInfo = codertarget.target.getTargetHardwareInfo(targetFolder, boardFolder, target);
end
%% ------------------------------------------------------------------------
function config = loc_createPILConfig
config(1) = rtw.connectivity.ConfigRegistry;
config(1).ConfigName = 'XILINX SDRZ';
config(1).ConfigClass = 'matlabshared.target.xilinxsdrz.ConnectivityConfig';
config(1).isConfigSetCompatibleFcn = @i_isConfigSetCompatible;
end
%% ------------------------------------------------------------------------
function isConfigSetCompatible = i_isConfigSetCompatible(configSet)
isConfigSetCompatible = false;
if configSet.isValidParam('CoderTargetData')
data = getParam(configSet,'CoderTargetData');
targetHardware = data.TargetHardware; 
hwSupportingPIL = { 'Xilinx Zynq Based Radio Board Target' };
for i=1:numel(hwSupportingPIL)
if isequal(hwSupportingPIL{i},targetHardware)
isConfigSetCompatible = true;
break
end
end
end
end
