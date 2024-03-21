%% QPSK Transmitter with ADALM-PLUTO Radio in Simulink
% This model shows how to use the ADALM-PLUTO Radio with Simulink(R) to
% implement a QPSK transmitter. The ADALM-PLUTO Radio in this model will
% keep transmitting indexed 'Hello world' messages at its specified center
% frequency. You can demodulate the transmitted message using the
% <matlab:openExample('plutoradio/QPSKReceiverWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradioQPSKReceiverSimulinkExample')
% QPSK Receiver with ADALM-PLUTO Radio> model. This example assumes that
% two ADALM-PLUTO Radios are attached to your computer.

% Copyright 2017-2022 The MathWorks, Inc.

%% Structure of the Example
% The top-level structure of the model is shown in the following figure:
modelname = 'plutoradioQPSKTransmitterSimulinkExample';
open_system(modelname);
set_param(modelname, 'SimulationCommand', 'update')
%%
% The transmitter includes the *Bit Generation* subsystem, the *QPSK
% Modulator* block, and the *Raised Cosine Transmit Filter* block. The *Bit
% Generation* subsystem uses a MATLAB workspace variable as the payload of
% a frame, as shown in the figure below. Each frame contains 100 'Hello
% world ###' messages and a header. The first 26 bits are header bits, a
% 13-bit Barker code that has been oversampled by two. The Barker code is 
% oversampled by two in order to generate precisely 13 QPSK symbols for 
% later use in the *Data Decoding* subsystem of the receiver model. The remaining 
% bits are the payload. The payload correspond to the ASCII representation of
% 'Hello world ###', where '###' is a repeating sequence of '000', '001',
% '002', ..., '099'. The payload is scrambled to guarantee a balanced 
% distribution of zeros and ones for the timing recovery operation in 
% the receiver model. The scrambled bits are modulated by the 
% *QPSK Modulator* (with Gray mapping). The modulated symbols are upsampled 
% by two by the *Raised Cosine Transmit Filter* with a roll-off factor 0.5. 
% The output rate of the *Raised Cosine Filter* is set to be 400k samples/second 
% with a symbol rate of 200k symbols per second. Please match the symbol
% rate of the transmitter model and the receiver model correspondingly.
%
open_system([modelname '/Bit Generation']);
%% Running the Example
% Before running the model, connect two ADALM-PLUTO Radios to the computer.
% Set the _Center frequency_ parameter of the *ADALM-PLUTO Radio
% Transmitter* block and run the model. You can run the
% <matlab:openExample('plutoradio/QPSKReceiverWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradioQPSKReceiverSimulinkExample')
% QPSK Receiver with ADALM-PLUTO Radio> model to receive the transmitted
% signal. We suggest initialize two MATLAB(R) sessions to ensure real-time
% process.
close_system([modelname '/Bit Generation']);
close_system(modelname, 0);
%% Exploring the Example
% Due to hardware variations among the ADALM-PLUTO Radios, a frequency offset 
% will likely exist between the transmitter hardware and the receiver hardware.
% In that case, perform a manual frequency calibration 
% using the companion frequency offset calibration 
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib') transmitter> and 
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib_rx') receiver> models and examine the resulting behavior.
% 
% If the message is not properly decoded by the receiver model, you can vary the gain of the 
% source signals in the *ADALM-PLUTO Radio Transmitter* block of this model, and that of
% the *ADALM-PLUTO Radio Receiver* block in the receiver model.
