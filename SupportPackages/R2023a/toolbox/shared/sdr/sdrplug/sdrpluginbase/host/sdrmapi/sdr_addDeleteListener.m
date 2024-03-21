function sdr_addDeleteListener(obj)

%  Copyright 2014 The MathWorks, Inc.

    addlistener(obj,'ObjectBeingDestroyed',@comm.internal.SDRSystemBase.handleDeleteNotification);
end
