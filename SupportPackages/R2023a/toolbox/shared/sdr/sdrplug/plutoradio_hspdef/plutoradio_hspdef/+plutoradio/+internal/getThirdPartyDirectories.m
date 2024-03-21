function dir3P = getThirdPartyDirectories

%  Copyright 2016-2017 The MathWorks, Inc.

dir3P.ADIFWDir = matlab.internal.get3pInstallLocation('analogdevices9361filterwizard.instrset');
dir3P.libiioDir = matlab.internal.get3pInstallLocation('libiio.instrset');