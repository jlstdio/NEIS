classdef rx< comm.libiio.AD9361.rx_control
% comm.libiio.AD9361.rx AD9361 Receiver System Object
%
% This system object provides access to the AD9361 receive
% functionality

     
    % Copyright 2015-2019 The MathWorks, Inc.

    methods
        function out=rx
            % RX Constructor method for comm.libiio.AD9361.rx
            %
            % Returns the comm.libiio.AD9361.rx object
        end

        function out=capture(~) %#ok<STOUT>
            % CAPTURE Capture contiguous data from the SDR board. 
            % 
            % [DATA,METADATA] = CAPTURE(RX,LENGTH) returns ceil(LENGTH) number of 
            % contiguous data samples captured from the SDR board using the RX 
            % system object. The output signal DATA is a column vector of 
            % complex double precision, single precision, or 16-bit integer values.
            % The number of columns in the matrix depends on the number of channels
            % in use, as specified by the ChannelMapping property of RX. Each column 
            % corresponds to a channel of complex data received on one channel.
            % METADATA is a structure containing metadata of the receiver setup
            % at the time of the capture. The structure contains these fields: 
            % Date, BasebandSampleRate, CenterFrequency, DeviceName, ChannelMapping, 
            % CaptureLengthSeconds, CaptureLengthSamples, SDRReceiverConfiguration, GainSource and DataContiguity.
            %
            % [DATA,METADATA] = CAPTURE(RX,LENGTH,UNIT) also 
            % specifies the unit measurement of LENGTH. Specify 
            % UNIT as 'Samples' (default) or 'Seconds'. When you specify 
            % 'Seconds', the function converts LENGTH seconds into N samples, 
            % based on the sampling rate of RX, and returns ceil(N) number of 
            % samples.
            %
            % [DATA,METADATA,BASEBANDFILENAME] = CAPTURE(...,'Filename',FILENAME) 
            % also specifies the filename of a comm.BasebandFileReader file <FILENAME>.bb. 
            % The function saves the captured data and metadata in this file and 
            % returns the name of the file in BASEBANDFILENAME.
            %
            % [DATA,METADATA,FILENAME] = CAPTURE(...,Name,Value) specifies optional
            % name-value pair arguments. Name must appear inside quotes. You can 
            % specify several name-value pair arguments in any order as Name1,
            % Value1,...,NameN,ValueN.
            %
            %   'Timestamp'    - Logical value true or false (default). Changes
            %                    the name of the created file to: 
            %                    <FILENAME>_<Year>-<Month>-<Day>_<Hour>-<Minute>-<Second>-<Millisecond>.bb
            %
            %   'UserMetadata' - Single-level structure. Structure fields are 
            %                    added to the output METADATA and to any 
            %                    created file. Field values must be of numeric,
            %                    logical, string, char or datetime type.
            %
            %   'EnableOversizeCapture' - Logical value true or false (default).
            %                             Overrides the general operation of the
            %                             function. Removes the limitation on
            %                             the maximum capture size and does not
            %                             guarantee data contiguity. If
            %                             discontiguity occurs,
            %                             METADATA.DataContiguity is false.
            %                             The function also returns METADATA.DiscontiguityIndices 
            %                             which provides a vector 
            %                             of row indices into output signal DATA. 
            %                             Each index indicates that on or after 
            %                             the corresponding data sample a
            %                             discontiguity occurs.
            %                             
            %
            % The function puts the RX object into a locked state. When the 
            % object is locked, you cannot change nontunable properties of the 
            % object. To unlock the object, call the release function on the 
            % object.
            %
            % See also comm.BasebandFileWriter, comm.BasebandFileReader
        end

        function out=setupImpl(~) %#ok<STOUT>
        end

    end
    properties
        % EnableBurstMode Enable burst mode
        %
        % Allows the collection of multiple frames that contain only contiguous
        % samples recieved from the hardware. The default is false.
        EnableBurstMode;

        % NumFramesInBurst Frames in burst
        %
        % Specify the number of frames to collect in a burst.
        % The default value is 1.
        NumFramesInBurst;

        % OutputDataType Output data type
        %
        % Output data type (complex data). The default type is int16.
        OutputDataType;

        % OverflowOutputPort Enable output port for overflow indicator
        %
        % Enable output port to indicate overflow.
        OverflowOutputPort;

        % OverrideSampleTime Override automatic sample time
        %        
        % Set to true, this property will allow you to specify the sample
        % time of the model manually. The default value is false, this
        % means the sample time will be derived from (Samples per
        % frame/Baseband sample rate).
        OverrideSampleTime;

        % SampleTime Sample time
        %
        % Input property for sample time. The default value is 0.02s.
        SampleTime;

        % SamplesPerFrame Samples per frame
        %
        % Frame size in samples. The default value is 20000.
        SamplesPerFrame;

        % kernelBuffersCount Kernel buffer depth
        %
        % Number of buffers used in the kernel circular queue
        kernelBuffersCount;

    end
end
