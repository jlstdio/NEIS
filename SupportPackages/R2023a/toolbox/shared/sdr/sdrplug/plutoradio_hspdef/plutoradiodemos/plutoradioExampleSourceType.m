classdef plutoradioExampleSourceType < uint8
  %plutoradioExampleSourceType CST Example source type values
  %
  %   See also plutoradioADSBExample, FMReceiverExample, FRSReceiverExample.
  
  %   Copyright 2017 The MathWorks, Inc.
  
  enumeration
    Simulated   (0)
    Captured    (1)
    RTLSDRRadio	(2)
    PlutoSDR  	(3)
  end
end