/*
 * Copyright 2015-2016 The MathWorks, Inc.
 */
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/ioctl.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <time.h>
#include <errno.h>
#include <math.h>
#include <stropts.h>
#include <poll.h>
#include <stdint.h>

/*
 * SDR Specific
 */
#include "sdrz_arm.h"
#include "sdrcapi_types.h"

#include "axi_lct.h"
#include "axi_interface.h"
#include "mwadma_ioctl.h"
#include "rtwtypes.h"


#define SDRZ_DEVICE "/dev/mwipcore"
#define SDRZ_TARGETED_DUT "/dev/mwipcore1"
#define NUM_RINGS 4
#define AXI_S_DATA_WIDTH 8 /* bytes */
#define BYTES_PER_CHANNEL_SAMPLE 4
#define MAX_CHANNELS_IN_AXI_S (AXI_S_DATA_WIDTH/BYTES_PER_CHANNEL_SAMPLE)


#define BYTES_PER_SAMPLE 8
#define MAX_CHAN_BYTES (1024*1024*64)
#define DEFAULT_RING_TOTAL (512) /* Number of rings */
#define DEFAULT_BD_BYTES (128*1024) /* PAGE_SIZE bytes per each buffer descriptor */
#define DEFAULT_INTERRUPT_SAMPLES (16384) /* Sample counter asserts TLAST at this number */
#define DEFAULT_RING_BYTES (MAX_CHAN_BYTES/DEFAULT_RING_TOTAL) /* Bytes per ring */
#define DEFAULT_INTERRUPT_BYTES (DEFAULT_INTERRUPT_SAMPLES*BYTES_PER_SAMPLE) 

/* Driver properties : base 0x10000 */
static const int32_t INTENC_RadioAddress      = 0x10100;
static const int32_t INTENC_sdrBlockType      = 0x10101;
static const int32_t INTENC_requester         = 0x10102;
static const int32_t INTENC_driverLib         = 0x10103;

/* Host data path props : base=0x30000 */
static const int32_t INTENC_OutputDataType    = 0x30001;
static const int32_t INTENC_SamplesPerFrame   = 0x30002;
static const int32_t INTENC_EnableBurstMode   = 0x30003;
static const int32_t INTENC_NumFramesInBurst  = 0x30004;
static const int32_t INTENC_DataIsComplex     = 0x30005;
static const int32_t INTENC_DataStreamCount   = 0x30006;
static const int32_t INTENC_SampleRate        = 0x30007;

static const int32_t INTENC_Rx_DMATimeoutValue = 0x30101;
static const int32_t INTENC_Tx_DMATimeoutValue = 0x30201;
static const int32_t INTENC_EnableTxPacketMode   = 0x30202;

static const int32_t INTENC_Overflow       = 0x30009;
/* Host datapath meta data props : base=0x30000, offset=0x100 */
static const int32_t INTENC_LostSamples       = 0x30100;
/*
 * forward declaration
 */

static uint8_t *sampleBuf;
static SDRBlockTypeT sdrBlockType = 0;

typedef struct data_path_params
{
    SDRBlockTypeT type; /* store block type */
    int32_t enabled; /* is this instance in use */
    int32_t initDone; /* has initialization been completed */
    uint32_t samplesPerFrame; /* step size */
    uint32_t outputDataType; /* Data type of input/output */
    uint32_t numberOfChannels; /* how many channels of data */
    double sampleRate; /* Rate in samples per second */
    uint32_t sampleSize; /* bytes per data sample */
    double DMATimeoutValue;
    uint8_t lostSamples;
} __attribute__((__packed__)) dataPathParams;

static dataPathParams txDataPath = {0};
static uint8_t enableTxPrimingMode = 0;
static int txPrimingLevel = 0;
static dataPathParams rxDataPath = {0};
static int rxDataPathResetDone = 0; // To ensure the rx path is only reset once in the Tx+Rx case

static int32_t *m_ridx;
static int32_t *m_iidx;

static int stop_sdr_firmware();

static void unpackProps(const int32_t cfgbufSize, const uint8_t * cfgbuf);

static void packProperty(int32_t intenc, int32_t * const sampleMetaDataSize, uint8_t * const sampleMetaData, uint8_t lostSamples);
static void packRxMetaData(int32_t * const sampleMetaDataSize, uint8_t * const sampleMetaData, uint8_t lostSamples);
static void packTxMetaData(int32_t * const sampleMetaDataSize, uint8_t * const sampleMetaData, uint8_t lostSamples);

void setupImplARM_c (
    const int32_t creationArgsSize,
    const uint8_t * const creationArgs, 
    const int32_t nonTunablePropsSize,
    const uint8_t * const nonTunableProps, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps, 
    const int32_t * driverHandle);

void processTunedPropertiesImplARM_c(const int32_t setPropValsSize, const uint8_t * const setPropVals);

void rxStepImplARM_c(int32_t * const sampleDataSize, 
    uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData);

void txStepImplARM_c(const int32_t sampleDataSize, 
    const uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData);

void txStepImplVoidARM_c(const int32_t sampleDataSize, 
    const void * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData);

void setConfigurationARM_c(const int32_t setPropValsSize, const uint8_t * const setPropVals);

void getConfigurationARM_c (const int32_t propListToGetSize, 
        const uint8_t * const propListToGet, 
        int32_t * const actualPropValsSize,
        uint8_t * const actualPropVals);

void releaseImplARM_c();

/* from sdrdatapath.hpp */
static const int16_t scaling = (1 << 15) - 1;
 

static inline int16_t doubleToInt16(double d)
                {if(d+0.5>INT16_MAX){return INT16_MAX;}
                if(d-0.5<INT16_MIN){return INT16_MIN;}
                if(d>0.0){return (int16_t)(d+0.5);}
                else{return (int16_t)(d-0.5);}};


static size_t calculate_descriptor_len(size_t bytes_per_ring);

/*
 **************************************************************************
 */
/* 
 * from "xparameters.h"
 */
#define XPAR_AXI_LITE_SYSTEM_CONFIG_PCORE_0_BASEADDR 0x72200000

#define  SYSTEM_CONFIG_AXI_BASE_ADDRESS						     (XPAR_AXI_LITE_SYSTEM_CONFIG_PCORE_0_BASEADDR) // Vivado uses a different naming convention
#define  wr_rxstrmenb_reg_Data_axi_lite_system_config_pcore      0x128  //data register for port wr_rxstrmenb_reg
#define  rd_rxstrmenb_reg_Data_axi_lite_system_config_pcore      0x12C  //data register for port rd_rxstrmenb_reg
#define  wr_txstrmenb_reg_Data_axi_lite_system_config_pcore      0x13C  //data register for port wr_txstrmenb_reg
#define  rd_txstrmenb_reg_Data_axi_lite_system_config_pcore      0x140  //data register for port rd_txstrmenb_reg

int32_t rx_data_stream_init(void)
{
	return 0;
}

int32_t rx_data_stream_en(void)
{
	Reg_Out32(SYSTEM_CONFIG_AXI_BASE_ADDRESS+wr_rxstrmenb_reg_Data_axi_lite_system_config_pcore, 0x01);
	return 0;
}

int32_t rx_data_stream_dis(void)
{
	Reg_Out32(SYSTEM_CONFIG_AXI_BASE_ADDRESS+wr_rxstrmenb_reg_Data_axi_lite_system_config_pcore, 0x00);
	return 0;
}

int32_t rx_data_stream_reset(void)
{
	Reg_Out32(SYSTEM_CONFIG_AXI_BASE_ADDRESS+wr_rxstrmenb_reg_Data_axi_lite_system_config_pcore, 0x02);
	return 0;
}

int32_t rx_data_hwburst_en(void)
{
    /* NOP in ARM SW Generation */
    return 0;
}

int32_t rx_data_hwburst_dis(void)
{
    /* NOP in ARM SW Generation */
    return 0;
}

int32_t tx_data_stream_init(void)
{
	return 0;
}

int32_t tx_data_stream_en(void)
{
	Reg_Out32(SYSTEM_CONFIG_AXI_BASE_ADDRESS+wr_txstrmenb_reg_Data_axi_lite_system_config_pcore, 0x01);
	return 0;
}

int32_t tx_data_stream_dis(void)
{
	Reg_Out32(SYSTEM_CONFIG_AXI_BASE_ADDRESS+wr_txstrmenb_reg_Data_axi_lite_system_config_pcore, 0x00);
	return 0;
}

int32_t tx_data_stream_reset(void)
{
	Reg_Out32(SYSTEM_CONFIG_AXI_BASE_ADDRESS+wr_txstrmenb_reg_Data_axi_lite_system_config_pcore, 0x02);
	return 0;
}

int32_t tx_data_hwburst_en(void)
{
    /* NOP in ARM SW Generation */
    return 0;
}

int32_t tx_data_hwburst_dis(void)
{
    /* NOP in ARM SW Generation */
    return 0;
}




/*
 **************************************************************************
 */

/*
 * @brief unpackInt32Scalar
 */
static int32_t unpackInt32Scalar(int32_t valsize, uint8_t * val) 
{ 
	int32_t retVal;

    if (valsize!=sizeof(int32_t))
    {
        fprintf(stderr,"wrong config size: valsize:%d, value:%d\n",valsize,*( (int32_t *)(val)));
        exit(EXIT_FAILURE);
    }
    retVal = *((int32_t*)(val));
    return retVal;
}
/*
 * @brief packInt32Scalar
 */
static void packInt32Scalar(int32_t val, int32_t * const propsSize, uint8_t *
        const props) 
{
    memcpy(props+(*propsSize), &val, sizeof(int32_t));
    *propsSize = *propsSize + sizeof(int32_t);
}
/*
 * @brief packUInt8Vector
 */
static void packUInt8Vector(int32_t valSize, uint8_t * val, 
                              int32_t * const propsSize, uint8_t * const props) 
{
    memcpy(props+(*propsSize), val, valSize);
    *propsSize = *propsSize + valSize;
}
static void packInt8Scalar(int8_t val, int32_t * const propsSize, uint8_t *
        const props) 
{
    memcpy(props+(*propsSize), &val, sizeof(int8_t));
    *propsSize = *propsSize + sizeof(int8_t);
}

/*
 * @brief unpackProps
 */
void unpackProps(const int32_t cfgbufSize, const uint8_t * cfgbuf)
{
    uint8_t * cfgbufPtr = (uint8_t *)(cfgbuf);

    int32_t intenc  = unpackInt32Scalar(4, cfgbufPtr); cfgbufPtr += 4;
    int32_t valsize = unpackInt32Scalar(4, cfgbufPtr); cfgbufPtr += 4;

    while (cfgbufPtr != NULL) {
        if(INTENC_sdrBlockType == intenc) /* We need to find out if we are Rx/Tx */
        {
                sdrBlockType = (SDRBlockTypeT)(unpackInt32Scalar(valsize, cfgbufPtr));
        }
        if (cfgbufPtr != NULL) {
            cfgbufPtr = cfgbufPtr + valsize;
            if ((cfgbufPtr - cfgbuf) < cfgbufSize) {
                intenc    = unpackInt32Scalar(4, cfgbufPtr); cfgbufPtr += 4;
                valsize   = unpackInt32Scalar(4, cfgbufPtr); cfgbufPtr += 4;
            } else {
                cfgbufPtr = NULL;
            }
        }
    }
}
/* --------------- outgoing Rx meta-data --------------- */
/* could be auto-generated from built-in specs */
void packProperty(int32_t intenc, int32_t * const sampleMetaDataSize, uint8_t * const sampleMetaData, uint8_t val) 
{
    if(intenc == INTENC_LostSamples)
    {
        packInt32Scalar(intenc, sampleMetaDataSize, sampleMetaData);
        packInt32Scalar(1, sampleMetaDataSize, sampleMetaData);
        packInt8Scalar((int8_t)(val), sampleMetaDataSize, sampleMetaData);
    }
    else if(intenc == INTENC_Overflow)
    {
        packInt32Scalar(intenc, sampleMetaDataSize, sampleMetaData);
        packInt32Scalar(1, sampleMetaDataSize, sampleMetaData);
        packInt8Scalar((int8_t)(val), sampleMetaDataSize, sampleMetaData);
    }
    else
    {
        fprintf(stderr, "Unrecognised property value: 0x%X\n", intenc);
        fflush(stderr);
    }
}

/*could be auto-generated from built-in specs */
void packRxMetaData(int32_t * const sampleMetaDataSize, uint8_t * const sampleMetaData, uint8_t val) 
{
    packProperty(INTENC_LostSamples, sampleMetaDataSize, sampleMetaData, val);
}


/* could be auto-generated from built-in specs */
void packTxMetaData(int32_t * const sampleMetaDataSize, uint8_t * const sampleMetaData, uint8_t val) 
{
    packProperty(INTENC_LostSamples, sampleMetaDataSize, sampleMetaData, val);
}
/*
 * @brief InitReceiveDataPath
 */
static void InitReceiveDataPath()
{
    int32_t stat;

    stat = SetReset(RXFPGA_DEV);
    if (stat) 
    {
        fprintf(stderr,"Error resetting FPGA device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- SetReset(RXFPGA_DEV) Success \n");
    }

    stat = SetReset(RXRFBOARD_DEV);
    if (stat)
    {
        fprintf(stderr,"Error initializing RF Board device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- InitAction(RXRFBOARD_DEV) Success \n");
    }    

    stat = InitAction(RXFPGA_DEV);
    if (stat)
    {
        fprintf(stderr,"Error initializing RF Board device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- InitAction(RXRFBOARD_DEV) Success \n");
    }    

    stat = InitAction(RXRFBOARD_DEV);
    if (stat)
    {
        fprintf(stderr,"Error initializing RF Board device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- InitAction(RXRFBOARD_DEV) Success \n");
    }   
}

/*
 * @brief InitTransmitDataPath
 */
static void InitTransmitDataPath()
{
    int32_t stat;
    
    stat = SetReset(TXFPGA_DEV);
    if (stat) 
    {
        fprintf(stderr,"Error resetting FPGA device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- SetReset(TXFPGA_DEV) Success \n");
    }

    stat = SetReset(TXRFBOARD_DEV);
    if (stat)
    {
        fprintf(stderr,"Error initializing RF Board device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- InitAction(TXRFBOARD_DEV) Success \n");
    }    

    stat = InitAction(TXFPGA_DEV);
    if (stat)
    {
        fprintf(stderr,"Error initializing RF Board device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- InitAction(TXRFBOARD_DEV) Success \n");
    }    

    stat = InitAction(TXRFBOARD_DEV);
    if (stat)
    {
        fprintf(stderr,"Error initializing RF Board device through SDR protocol. stat=%d\n",stat);
        fflush(stdout);
        exit(EXIT_FAILURE);
    } else {
        fprintf(stderr,"--- InitAction(TXRFBOARD_DEV) Success \n");
    }   
}

/*
 * @brief stop_sdr_firmware
 */
static int stop_sdr_firmware(){
    FILE *fp;
    int signo = -1;
    int ret = 0;
    fp = popen("pgrep sdr_firmware","r");
    if (fp == NULL) {
        fprintf(stderr,"Failed to read the signal number of sdr_firmware.\n");
        exit(EXIT_FAILURE);
    }
    fscanf(fp,"%d",&signo);
    pclose(fp);
    if (-1 == signo) {
        MW_DBG_text( "sdr_firmware is not running\n");
    } else {
        MW_DBG_printf( "Terminating sdr_firmware with PID:%d\n",signo);
        ret = kill(signo, SIGTERM);
    }
    return ret;
}

/*
 * @brief calculate_descriptor_len
 */
static size_t calculate_descriptor_len(size_t bytes_per_ring)
{
    size_t max_desc_size = DEFAULT_BD_BYTES;
    uint32_t descriptor_per_ring = 1;
    
    if(bytes_per_ring <= max_desc_size)
    {
        descriptor_per_ring = 1;
    }
    else if((bytes_per_ring % max_desc_size) == 0) /* ring will be an integer multiple of max descriptor */
    {
        descriptor_per_ring = bytes_per_ring/max_desc_size;
    }
    else
    {
        descriptor_per_ring = bytes_per_ring/max_desc_size;

        /* find next power of two to allow for even division */
        descriptor_per_ring--;
        descriptor_per_ring |= descriptor_per_ring >> 1;
        descriptor_per_ring |= descriptor_per_ring >> 2;
        descriptor_per_ring |= descriptor_per_ring >> 4;
        descriptor_per_ring |= descriptor_per_ring >> 8;
        descriptor_per_ring |= descriptor_per_ring >> 16;
        descriptor_per_ring++;
    }
        return bytes_per_ring/descriptor_per_ring;
}

/*
 * setupImplARM_c
 */
void setupImplARM_c (
    const int32_t creationArgsSize,
    const uint8_t * const creationArgs, 
    const int32_t nonTunablePropsSize,
    const uint8_t * const nonTunableProps, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps, 
    const int32_t * driverHandle) {
    int32_t stat;
    int i;

    int32_t * drvHandle = (int32_t *) driverHandle;
    *drvHandle = 17725;
    static int initDone = 0;

    unpackProps(creationArgsSize, creationArgs);
    if(SDRRxBlock == sdrBlockType)
    {
        rxDataPath.type = SDRRxBlock;
        rxDataPath.enabled++;
        MW_DBG_text("Called by an Rx block.\n");
    }
    else if(SDRTxBlock == sdrBlockType)
    {
        txDataPath.type = SDRTxBlock;
        txDataPath.enabled++;
        MW_DBG_text("Called by an Tx block.\n");
    }
    else
    {
        MW_DBG_printf("Block type = %d\n", sdrBlockType);
    }

    if (!initDone) {
        stat = stop_sdr_firmware();
        if (stat) {
            perror("Failed to terminate sdr_firmware.");
            fprintf(stderr,"ARM Application will not run properly.\n");
        } else {
            MW_DBG_text("Sucessfully stopped SDR Firmware application.\n");
        }

        if(InitFromBoot() < 0)
        {
            fprintf(stderr,"Error initializing InitFromBoot. stat=%d\n",stat);
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            MW_DBG_text("--- InitFromBoot Success \n");
        }

        stat = SetReset(FPGA_DEV);
        if (stat) 
        {
            fprintf(stderr,"Error resetting FPGA device through SDR protocol. stat=%d\n",stat);
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            MW_DBG_text("--- SetReset(FPGA_DEV) Success \n");
        }
        
        stat = SetReset(RFBOARD_DEV);
        if (stat) 
        {
            fprintf(stderr,"Error resetting FPGA device through SDR protocol. stat=%d\n",stat);
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            MW_DBG_text("--- SetReset(FPGA_DEV) Success \n");
        }
        
        stat = InitAction(FPGA_DEV);
        if (stat) 
        {
            fprintf(stderr,"Error initializing FPGA device through SDR protocol. stat=%d\n",stat);
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            MW_DBG_text("--- InitAction(FPGA_DEV) Success \n");
        }        
        
        stat = InitAction(RFBOARD_DEV);
        if (stat) 
        {
            fprintf(stderr,"Error initializing FPGA device through SDR protocol. stat=%d\n",stat);
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            MW_DBG_text("--- InitAction(RFBOARD_DEV) Success \n");
        }
    }
    
    /* Pre-configuration */

    if(!rxDataPath.initDone && rxDataPath.enabled)
    {
        InitReceiveDataPath();
    }
    
    if(!txDataPath.initDone && txDataPath.enabled)
    {
        InitTransmitDataPath();
    }
    
    setConfigurationARM_c(nonTunablePropsSize, nonTunableProps);
    MW_DBG_text( "--- Set nonTunablePropsSize - done...\n");
    
    setConfigurationARM_c(tunablePropsSize, tunableProps);
    MW_DBG_text( "--- Set TunableProperties - done...\n");
    
    /* by default we will always read the raw 16-bits */
    
    /* Post-configuration */

    if (!initDone) {
        size_t counter = DEFAULT_INTERRUPT_SAMPLES;
        size_t bytes_per_ring = DEFAULT_RING_BYTES;
        size_t descriptor_len = DEFAULT_BD_BYTES;
        size_t total_rings = DEFAULT_RING_TOTAL;
        size_t totalsize = MAX_CHAN_BYTES;
        for (i=0;i<__MW_AXI4STREAM_READ__;i++) {
             AXI4STREAM_INIT(SDRZ_DEVICE, counter, totalsize, bytes_per_ring, bytes_per_ring, total_rings, AXIREAD);
        }
        for (i=0;i<__MW_AXI4STREAM_WRITE__;i++) {
            AXI4STREAM_INIT(SDRZ_DEVICE, counter, totalsize, bytes_per_ring, bytes_per_ring, total_rings, AXIWRITE);
        }
        initDone = 1; /* Only do once */
    }
    if(!rxDataPath.initDone && rxDataPath.enabled)
    {
        /* a sample is int16(c) * # channels */
        rxDataPath.sampleSize = sizeof(int16_t) * 2 * rxDataPath.numberOfChannels;
        MW_DBG_printf( "--- Total Rx bytes = %d...\n",(unsigned int) (rxDataPath.samplesPerFrame * rxDataPath.sampleSize));
        size_t counter = (rxDataPath.samplesPerFrame*rxDataPath.numberOfChannels)/MAX_CHANNELS_IN_AXI_S;
        size_t bytes_per_ring = (size_t) (rxDataPath.samplesPerFrame * rxDataPath.sampleSize);
        size_t descriptor_len = calculate_descriptor_len(bytes_per_ring);
        size_t total_rings = NUM_RINGS;
        size_t totalsize = NUM_RINGS * bytes_per_ring;

        if(!rxDataPathResetDone) /* This doesn't need to be done if the Rx reset has been done by a Tx Block */
        {
            DisableAction(RXFPGA_DEV);
            SetReset(RXFPGA_DEV); 
            rxDataPathResetDone = 1;
        }

        AXI4STREAM_SETRXTIMEOUT(rxDataPath.DMATimeoutValue);
        AXI4STREAM_UPDATERXCHANNEL(counter, totalsize, bytes_per_ring, descriptor_len, total_rings);
        rxDataPath.initDone = 1; /* only do rx once */
    }
    
    if(!txDataPath.initDone && txDataPath.enabled)
    {     
        /* a sample is int16(c) * # channels */
        txDataPath.sampleSize = sizeof(int16_t) * 2 * txDataPath.numberOfChannels;
        MW_DBG_printf( "--- Total Tx bytes = %d...\n",(unsigned int) (txDataPath.samplesPerFrame * txDataPath.sampleSize));
        size_t counter = (txDataPath.samplesPerFrame*txDataPath.numberOfChannels)/MAX_CHANNELS_IN_AXI_S;
        size_t bytes_per_ring = (size_t) (txDataPath.samplesPerFrame * txDataPath.sampleSize);
        size_t descriptor_len = calculate_descriptor_len(bytes_per_ring);
        size_t total_rings = NUM_RINGS;
        size_t totalsize = NUM_RINGS * bytes_per_ring;

        sampleBuf = malloc(txDataPath.samplesPerFrame * txDataPath.sampleSize);
        m_ridx = malloc(txDataPath.numberOfChannels*sizeof(*m_ridx));
        m_iidx = malloc(txDataPath.numberOfChannels*sizeof(*m_iidx));
        for(i = 0; i < txDataPath.numberOfChannels; i++)
        {
            m_ridx[i] = i*txDataPath.samplesPerFrame;
            m_iidx[i] = (i+txDataPath.numberOfChannels)*txDataPath.samplesPerFrame;
        }

        /* TODO: Alter HW to use tx stream reset OR rx stream reset 
         * We may have a situation that a tx+rx DUT is targeted but we don't
         * have an Rx system object/block in the model. currently the reset is
         * connected to the Rx
         */
        if(!rxDataPathResetDone) /* This doesn't need to be done if the Rx reset has been done by an Rx Block */
        {
            DisableAction(RXFPGA_DEV);
            SetReset(RXFPGA_DEV); /* This resets the core in tx/rx mode */
            rxDataPathResetDone = 1;
        }
        DisableAction(TXFPGA_DEV);
        SetReset(TXFPGA_DEV);

        AXI4STREAM_SETTXTIMEOUT(txDataPath.DMATimeoutValue);
        AXI4STREAM_UPDATETXCHANNEL(totalsize, bytes_per_ring, descriptor_len, total_rings);
        if(enableTxPrimingMode)
        {
            /* Load two frames of data before enabling transmit */
            txPrimingLevel = 2; 
        }
        else
        {
            /* After loading one frame we can enable transmit */
            txPrimingLevel = 1; 
        }
        txDataPath.initDone = 1; /* only do tx once */
    }
}

/*
 * @brief processTunedPropertiesImplARM_c
 */
void processTunedPropertiesImplARM_c(const int32_t setPropValsSize, const uint8_t * const setPropVals)
{
    setConfigurationARM_c(setPropValsSize, setPropVals);
}

/*
 * @brief rxStepImplARM_c
 */
void rxStepImplARM_c(int32_t * const sampleDataSize, 
    uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData) {
    int status;
    int stat;
    int32_t * mDSize = (int32_t*) sampleMetaDataSize;
    int32_t * dSize = (int32_t *)sampleDataSize;
    static uint8_t streamStarted = 0;
    *mDSize = 0;
    static unsigned int ct = 0;
    int underflowFlag = 0, overflowFlag = 0;

    if (!streamStarted) {
    stat = EnableAction(RXFPGA_DEV);
        if(stat  <  0) {
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            fflush(stdout);
            streamStarted = 1;
        }
    }
    status = AXI4STREAM_READCONTINUOUS((uint8_t *)sampleData, &overflowFlag, &underflowFlag);
    if (underflowFlag) {
        /* No interrupt received */
        *dSize = 0;
    } else {
        *dSize = rxDataPath.samplesPerFrame;
    }
    packRxMetaData(sampleMetaDataSize,sampleMetaData,(uint8_t)overflowFlag);
    // DisableAction(RXFPGA_DEV);
}

/*
 * @brief txStepImplVoidARM_c
 */
void txStepImplVoidARM_c(const int32_t sampleDataSize, 
    const void * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData)
{
    int status;
    int32_t * mDSize = (int32_t*) sampleMetaDataSize;
    static uint8_t streamStarted = 0;
    *mDSize = 0;
    int16_t temp[2]; // real, imag
    uint32_t i,j;
    int underflowFlag = 0, overflowFlag = 0;
    int numOfFramesToPrime = 0;
    static int frameCount = 0;  /* Used to track priming */
    

    switch (txDataPath.outputDataType) 
    { 
        case DTypeCInt16:
            {
                cint16_T *d = (cint16_T*)sampleBuf;
                int16_t * source = (int16_t *)(sampleData);
                for (i=0; i<txDataPath.samplesPerFrame; i++) 
                {
                    for (j=0; j<txDataPath.numberOfChannels; j++)
                    {
                        temp[0] = *(source+m_ridx[j]+i); /* Real */
                        temp[1] = *(source+m_iidx[j]+i); /* Imaginary */
                        d[txDataPath.numberOfChannels*i+j].re = temp[0];
                        d[txDataPath.numberOfChannels*i+j].im = temp[1];
                        // printf("%d %d;\n", temp[0],temp[1]);

                    }

                }
            }
            break;

        case DTypeCDouble: 
            {
                cint16_T *d = (cint16_T*)sampleBuf;
                real_T * source = (real_T *)(sampleData);
                for (i=0; i<txDataPath.samplesPerFrame; i++) 
                {
                    for (j=0; j<txDataPath.numberOfChannels; j++)
                    {
                        temp[0] = (int16_t)(doubleToInt16(*(source+m_ridx[j]+i) * scaling)); /* Real */
                        temp[1] = (int16_t)(doubleToInt16(*(source+m_iidx[j]+i) * scaling)); /* Imaginary */
                        d[txDataPath.numberOfChannels*i+j].re = temp[0];
                        d[txDataPath.numberOfChannels*i+j].im = temp[1];
                        /*MW_DBG_printf("%d %d;\n", temp[0],temp[1]);*/
                    }
                }
            }
            break;

        case DTypeCSingle: 
            {
                cint16_T *d = (cint16_T*)sampleBuf;
                real32_T * source = (real32_T *)(sampleData);
                for (i=0; txDataPath.samplesPerFrame; i++) 
                {
                    for (j=0; j<txDataPath.numberOfChannels; j++)
                    {
                        temp[0] = (int16_t)(doubleToInt16(*(source+m_ridx[j]+i) * scaling)); /* Real */
                        temp[1] = (int16_t)(doubleToInt16(*(source+m_iidx[j]+i) * scaling)); /* Imaginary */
                        d[txDataPath.numberOfChannels*i+j].re = temp[0];
                        d[txDataPath.numberOfChannels*i+j].im = temp[1];
                        /*MW_DBG_printf("%d %d;\n", temp[0],temp[1]);*/
                    }
                }
            }
            break;

        default:
            fprintf(stderr, "unsupported tx data type\n");
            exit(EXIT_FAILURE);
            break;
    }

    if(enableTxPrimingMode)
    {
        status = AXI4STREAM_WRITECONTINUOUS(sampleBuf, &overflowFlag, &underflowFlag);
    }
    else
    {
        status = AXI4STREAM_WRITEWITHSIGNALS(sampleBuf, &overflowFlag, &underflowFlag);
    }

    if(!streamStarted)
    {
        //underflowFlag = 0; /* Mask */
        /* Only enable the Tx stream when we have enough frames sent to the FIFO */
        if((++frameCount) == txPrimingLevel) /* Enable transmit path when primed */
        {
            status = EnableAction(TXFPGA_DEV);
            if(status  <  0) {
                fflush(stdout);
                exit(EXIT_FAILURE);
            } else {
                fflush(stdout);
                streamStarted = 1;
            }
        }

    }

    /* packTxMetaData */
    packProperty(INTENC_LostSamples, sampleMetaDataSize, sampleMetaData, underflowFlag);
    packProperty(INTENC_Overflow, sampleMetaDataSize, sampleMetaData, overflowFlag);

}
/*
 * @brief txStepImplARM_c
 */
void txStepImplARM_c(const int32_t sampleDataSize, 
    const uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData)
{
    int status;
    int32_t * mDSize = (int32_t*) sampleMetaDataSize;
    static uint8_t streamStarted = 0;
    *mDSize = 0;
    int16_t temp[2]; // real, imag
    uint32_t i,j;
    /*static int ct = 0;
    MW_DBG_printf("%s\n, call:%d",__func__,ct);
    ct++;*/
    
    if (!streamStarted) {
    status = EnableAction(TXFPGA_DEV);
        if(status  <  0) {
            fflush(stdout);
            exit(EXIT_FAILURE);
        } else {
            fflush(stdout);
            streamStarted = 1;
        }
    }

    status = AXI4STREAM_WRITE(sampleData, sampleDataSize);
    if (status) {
        /* No interrupt received */
    } else {
    }
}
/*
 * @brief setConfigurationARM_c
 */
void setConfigurationARM_c(const int32_t setPropValsSize, const uint8_t * const setPropVals)
{
    static int ct = 0;
    
    int32_t retVal = 0;
    uint8_t * setBufPtr = (uint8_t *)setPropVals;
    uint8_t * inData;
    uint8_t * outData;
    

    int32_t intenc  = unpackInt32Scalar(4, setBufPtr); setBufPtr += 4;
    uint32_t valsize = unpackInt32Scalar(4, setBufPtr); setBufPtr += 4;

    while (setBufPtr != NULL) {
        MW_DBG_printf("SetProp: intenc - 0x%x, valsize - %d, setBufPtr - %d\n",intenc,valsize,*(uint32_t*)setBufPtr);
        inData = (uint8_t*)malloc(valsize);
        outData = (uint8_t*)malloc(valsize);

        /* Ensure data alignemnt before calling external library*/
        memcpy(inData,setBufPtr,valsize);

        retVal = SetProperty((uint32_t)intenc, (uint32_t)valsize, (uint8_t*)inData, (uint8_t*)outData);
        if (intenc == INTENC_SampleRate)
        {
            if(!rxDataPath.initDone && rxDataPath.enabled)
            {
                rxDataPath.sampleRate = *(double*) outData;
                MW_DBG_printf("Rx Sample rate = %f\n", rxDataPath.sampleRate);
                fflush(stdout);
            }
            if(!txDataPath.initDone && txDataPath.enabled)
            {
                txDataPath.sampleRate = *(double*) outData;
                MW_DBG_printf("Tx Sample rate = %f\n", txDataPath.sampleRate);
                fflush(stdout);
            }
        }
        if (intenc == INTENC_SamplesPerFrame)
        {
            if(!rxDataPath.initDone && rxDataPath.enabled)
            {
                rxDataPath.samplesPerFrame = *(uint32_t*) outData;
                MW_DBG_printf("Rx Samples per frame = %d\n",rxDataPath.samplesPerFrame);
                fflush(stdout);
            }
            if(!txDataPath.initDone && txDataPath.enabled)
            {
                txDataPath.samplesPerFrame = *(uint32_t*) outData;
                MW_DBG_printf("Tx Samples per frame = %d\n",txDataPath.samplesPerFrame);
                fflush(stdout);
            }
        }
        if (intenc == INTENC_DataStreamCount)
        {
            if(!rxDataPath.initDone && rxDataPath.enabled)
            {
                rxDataPath.numberOfChannels = *(uint32_t*) outData;
                MW_DBG_printf("Rx Number of Channels = %d\n",rxDataPath.numberOfChannels);
                fflush(stdout);
            }
            if(!txDataPath.initDone && txDataPath.enabled)
            {
                txDataPath.numberOfChannels = *(uint32_t*) outData;
                MW_DBG_printf("Tx Number of Channels = %d\n",txDataPath.numberOfChannels);
                fflush(stdout);
            }
        }
        if (intenc == INTENC_OutputDataType)
        {
            if(!rxDataPath.initDone && rxDataPath.enabled)
            {
                rxDataPath.outputDataType = *(uint32_t*) outData;
                MW_DBG_printf("Rx Output data-type = %d\n",rxDataPath.outputDataType);
                fflush(stdout);
            }
            if(!txDataPath.initDone && txDataPath.enabled)
            {
                txDataPath.outputDataType = *(uint32_t*) outData;
                MW_DBG_printf("Tx Output data-type = %d\n",txDataPath.outputDataType);
                fflush(stdout);
            }
        }
        if (intenc == INTENC_Rx_DMATimeoutValue)
        {
            if(!rxDataPath.initDone && rxDataPath.enabled)
            {
                rxDataPath.DMATimeoutValue = *(double*) outData;
                MW_DBG_printf("Rx DMA Timeout Value = %f\n",rxDataPath.DMATimeoutValue);
                fflush(stdout);
            }
        }
        if (intenc == INTENC_Tx_DMATimeoutValue)
        {
            if(!txDataPath.initDone && txDataPath.enabled)
            {
                txDataPath.DMATimeoutValue = *(double*) outData;
                MW_DBG_printf("Tx DMA Timeout Value = %f\n",txDataPath.DMATimeoutValue);
                fflush(stdout);
            }
        }
        if (intenc == INTENC_EnableTxPacketMode)
        {
            if(!txDataPath.initDone && txDataPath.enabled)
            {
                enableTxPrimingMode = *(uint8_t*) outData;
                MW_DBG_printf("Tx Priming mode = %d\n",(int)enableTxPrimingMode);
                fflush(stdout);
            }
        }
        free(inData);
        free(outData);
        if (retVal) { break; }

        if (setBufPtr != NULL) {
            /* This can cause setBufPtr to be unaligned */
            setBufPtr = setBufPtr + valsize;
            if ((setBufPtr - setPropVals) < setPropValsSize) {
                intenc    = unpackInt32Scalar(4, setBufPtr); setBufPtr += 4;
                valsize   = unpackInt32Scalar(4, setBufPtr); setBufPtr += 4;
            } else {
                setBufPtr = NULL;
            }
        }
    }
    if (retVal) {
        fprintf(stderr,"SetPropertyError: Error setting property through SDR protocol.\nProtocol ID: 0x%x, retVal: %d\n",intenc, retVal);
        exit(EXIT_FAILURE);
    }    
}
/*
 * @brief getConfigurationARM_c
 */
void getConfigurationARM_c (const int32_t propListToGetSize, 
        const uint8_t * const propListToGet, 
        int32_t * const actualPropValsSize,
        uint8_t * const actualPropVals)
{
    int32_t retVal = 0;
    uint8_t * propListBufPtr = (uint8_t *)propListToGet;

    uint32_t tmpPropSize = SDR_MAX_CONFIG_SIZE;
    uint8_t * tmpPropVal = (uint8_t *) malloc(SDR_MAX_CONFIG_SIZE);
    uint8_t * actPropBufPtr  = (uint8_t *)actualPropVals;

    int32_t intenc  = unpackInt32Scalar(4, propListBufPtr); propListBufPtr += 4;

    while (propListBufPtr != NULL) {

        packInt32Scalar(intenc, actualPropValsSize, actualPropVals);

        retVal = GetProperty(intenc, &tmpPropSize, tmpPropVal);

        if (retVal) { break; }

        packInt32Scalar(tmpPropSize, actualPropValsSize, actualPropVals);
        packUInt8Vector(tmpPropSize, (uint8_t *) tmpPropVal, actualPropValsSize, actualPropVals);

        if (propListBufPtr != NULL) {
            if ((propListBufPtr - propListToGet) < propListToGetSize) {
                intenc    = unpackInt32Scalar(4, propListBufPtr); propListBufPtr += 4;
            } else {
                propListBufPtr = NULL;
            }
        }
    }

    free(tmpPropVal);

    if (retVal) {
        fprintf(stderr,"Error getting property through SDR protocol.\nInt ID: %d\n", intenc);
        exit(EXIT_FAILURE);
    }
}
/*
 * @brief releaseImplARM_c
 */
void releaseImplARM_c()
{
    static char termDone = 0;
    MW_DBG_printf("--- Terminate : %s \n",__func__);
    fflush(stdout);
    if (!termDone){
        AXI4STREAM_TERMINATE();
        if(rxDataPath.enabled)
        {
            rxDataPath.enabled = 0;
            DisableAction(RXFPGA_DEV);
            SetReset(RXFPGA_DEV);
        }
        if(txDataPath.enabled)
        {
            txDataPath.enabled = 0;
            DisableAction(TXFPGA_DEV);
            SetReset(TXFPGA_DEV);
            free(sampleBuf);
            free(m_ridx);
            free(m_iidx);
        }
        SetReset(FPGA_DEV);
    }
    termDone = 1;
}



