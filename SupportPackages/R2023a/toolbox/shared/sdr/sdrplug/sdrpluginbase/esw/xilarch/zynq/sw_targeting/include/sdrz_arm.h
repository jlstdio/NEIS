/* Copyright 2015 The MathWorks, Inc. */
/* 
 * C-API for SDRZ ARM drivers
 *
 */
#ifndef __sdrzarm_h__
#define __sdrzarm_h__

#include <stdint.h>


#define setupImpl_c(creationArgsSize,creationArgs,nonTunablePropsSize,nonTunableProps,tunablePropsSize,tunableProps,driverHandle,a,b,c)  setupImplARM_c(creationArgsSize,creationArgs,nonTunablePropsSize,nonTunableProps,tunablePropsSize,tunableProps,driverHandle)
extern void setupImplARM_c (
    const int32_t creationArgsSize,
    const uint8_t * const creationArgs, 
    const int32_t nonTunablePropsSize,
    const uint8_t * const nonTunableProps, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps,
    const int32_t * driverHandle);
        
#define processTunedPropertiesImpl_c(driverHandle,setPropValsSize,setPropVals,a,b,c) processTunedPropertiesImplARM_c(setPropValsSize,setPropVals)
extern void processTunedPropertiesImplARM_c(const int32_t setPropValsSize, const uint8_t * const setPropVals);


#define rxStepImpl_c(driverHandle,sampleDataSize,sampleData,sampleMetaDataSize,sampleMetaData,f,g,h) rxStepImplARM_c(sampleDataSize,sampleData,sampleMetaDataSize,sampleMetaData)

extern void rxStepImplARM_c(int32_t * const sampleDataSize, 
    uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData);

#define txStepImpl_c(driverHandle,sampleDataSize,sampleData,sampleMetaDataSize,sampleMetaData,f,g,h)  txStepImplARM_c(sampleDataSize,sampleData,sampleMetaDataSize,sampleMetaData)
#define txStepImplVoid_c(driverHandle,sampleDataSize,sampleData,sampleMetaDataSize,sampleMetaData,f,g,h)  txStepImplVoidARM_c(sampleDataSize,sampleData,sampleMetaDataSize,sampleMetaData)

extern void txStepImplVoidARM_c(const int32_t sampleDataSize, 
    const void * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData);

extern void txStepImplARM_c(const int32_t sampleDataSize, 
    const uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData);


#define setConfiguration_c(driverHandle,setPropValsSize,setPropVals,a,b,c) setConfigurationARM_c(setPropValsSize,setPropVals)
extern void setConfigurationARM_c(const int32_t setPropValsSize, const uint8_t * const setPropVals);
        
#define getConfiguration_c(driverHandle,propListToGetSize,propListToGet,actualPropValsSize,actualPropVals,a,b,c) getConfigurationARM_c(propListToGetSize,propListToGet,actualPropValsSize,actualPropVals)
extern void getConfigurationARM_c (const int32_t propListToGetSize, 
        const uint8_t * const propListToGet, 
        int32_t * const actualPropValsSize,
        uint8_t * const actualPropVals);

#define releaseImpl_c(h,a,b,c) releaseImplARM_c()
extern void releaseImplARM_c();


int32_t rx_data_stream_init(void);
int32_t rx_data_stream_en(void);
int32_t rx_data_stream_dis(void);
int32_t rx_data_stream_reset(void);
int32_t rx_data_hwburst_en(void);
int32_t rx_data_hwburst_dis(void);

int32_t tx_data_stream_init(void);
int32_t tx_data_stream_en(void);
int32_t tx_data_stream_dis(void);
int32_t tx_data_stream_reset(void);
int32_t tx_data_hwburst_en(void);
int32_t tx_data_hwburst_dis(void);


/* from sdrcapi.h
#define SDR_MAX_STR_SIZE     1024
#define SDR_MAX_ERR_STR_SIZE 1024
#define SDR_MAX_DATA_SIZE    1024*300
#define SDR_MAX_CONFIG_SIZE  1024*5
*/

typedef enum {
    DTypeInt16=0,
    DTypeSingle,
    DTypeDouble,
    DTypeCInt16,
    DTypeCSingle,
    DTypeCDouble,
    DTypeMax
} SDRZPortDType_T;

/* From SDRCppIfT.hpp */
typedef enum { 
    SDRRxBlock=1, 
    SDRTxBlock=2, 
    SDRMbBlock=3 } SDRBlockTypeT;

//typedef struct _SDRManagerPropsT {
//    char           RadioAddress[SDR_MAX_STR_SIZE]; /* "192.168.10.2;192.168.20.2" (or usb id, ...) */
//    SDRBlockTypeT  sdrBlockType;                     /* rx, tx, mboard */
//    char           requester[SDR_MAX_STR_SIZE];      /* host obj -- for locking identification */
//    char           driverLib[SDR_MAX_STR_SIZE];      
//    int            firstDriverForRadio; /* originally a bool in the cpp host code */
//} SDRManagerPropsT;

#define FPGA_DEV	  	0x00
#define RXFPGA_DEV	  	0x01
#define TXFPGA_DEV	  	0x02
#define RFBOARD_DEV	  	0x03
#define RXRFBOARD_DEV 	0x04
#define TXRFBOARD_DEV 	0x05
#define PROTO_VER		0x100
#define FIRM_VER		0x101


extern int32_t SetReset(uint32_t dev);
extern int32_t InitAction(uint32_t dev);
extern int32_t EnableAction(uint32_t dev);
extern int32_t InitFromBoot(void);
extern int32_t SetProperty(uint32_t prop, uint32_t dlen, uint8_t* data, uint8_t* rdata);
extern int32_t GetProperty(uint32_t prop, uint32_t* dlen, uint8_t* rdata);

extern void Reg_Out32(uint32_t addr, uint32_t val);
extern int32_t DisableAction(uint32_t dev);

#endif

