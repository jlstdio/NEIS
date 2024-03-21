classdef SDRSystemBase< matlab.System & comm.internal.SDRSystemBase_propdefs
% SDRSystemBase Base class for SDR plugin system objects

 
% Copyright 2014-2018 The MathWorks, Inc.

    methods
        function out=SDRSystemBase
        end

        function out=checkForError(~) %#ok<STOUT>
        end

        function out=connect(~) %#ok<STOUT>
        end

        function out=dialogLayout(~) %#ok<STOUT>
        end

        function out=disconnect(~) %#ok<STOUT>
        end

        function out=getDescriptiveName(~) %#ok<STOUT>
        end

        function out=getQuantizedValue(~) %#ok<STOUT>
        end

        function out=handleDeleteNotification(~) %#ok<STOUT>
        end

        function out=infoImpl(~) %#ok<STOUT>
        end

        function out=initProps(~) %#ok<STOUT>
        end

        function out=initPropsAndConnect(~) %#ok<STOUT>
        end

        function out=isInputComplexityMutableImpl(~) %#ok<STOUT>
        end

        function out=isInputSizeMutableImpl(~) %#ok<STOUT>
        end

        function out=isNotGeneratingHDL(~) %#ok<STOUT>
        end

        function out=isSupportedContext(~) %#ok<STOUT>
        end

        function out=packPropertyList(~) %#ok<STOUT>
        end

        function out=releaseImpl(~) %#ok<STOUT>
        end

        function out=requiresTargetConnection(~) %#ok<STOUT>
        end

        function out=resetImpl(~) %#ok<STOUT>
        end

        function out=setPropertyList(~) %#ok<STOUT>
        end

        function out=setPropertyValue(~) %#ok<STOUT>
        end

        function out=setupImpl(~) %#ok<STOUT>
        end

        function out=stepImpl(~) %#ok<STOUT>
        end

        function out=unpackRxData(~) %#ok<STOUT>
        end

        function out=updateTunable(~) %#ok<STOUT>
        end

        function out=warnOnError(~) %#ok<STOUT>
        end

    end
    methods (Abstract)
        assignTunablePropsInputs;

        assignTunablePropsNoInputs;

        enumToInt;

        getIntEncoding;

        getQuantizedValues;

        initStaticProps;

        packCreationGroupProps;

        packNontunableGroupProps;

        packProperty;

        packTunableGroupProps;

        setNontunableGroupProps;

        setTunableGroupProps;

        %unpackRxData(obj, dataSize, data)
        %[psize, pbytes] = packTxData(obj, dataIn)
        unpackMetaData;

        unpackProperty;

    end
    properties
        CreationPropsListBase;

        DeviceName;

        RadioAddress;

        carrierBoard;

        driverLib;

        pDataElemSize;

        pDataFrameSize;

        pDriverHandle;

        pGetQuantizedMode;

        pLastTunablePackedBuffer;

        pLastTunablePackedSize;

        pRxData;

        pRxDataInt16C;

        pRxScaleFactor;

        pTxDataIsComplex;

        pTxNumChannels;

        pTxOutputDataType;

        pTxSampleRate;

        pTxSamplesPerFrame;

        pTxScaleFactor;

        radioBoard;

        sdrBlockType;

    end
end
