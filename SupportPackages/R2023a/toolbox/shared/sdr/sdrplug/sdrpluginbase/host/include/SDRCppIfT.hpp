/* Copyright 2014-2015 The MathWorks, Inc. */
/* 
 * C++ SDR driver interface
 *
 */
#ifndef __SDRCppIfT_hpp__
#define __SDRCppIfT_hpp__

#include "tmwtypes.h"
#include <boost/shared_ptr.hpp>
#include <tamutil/PluginLoader.hpp>
#include <sdrutils/sdr_exception.hpp> // exceptions
#include "sdrcapi_types.h" // SDRPluginStatusT


typedef tamutil::PluginLoader * PluginLoaderPtr;

typedef enum { 
    SDRRxBlock=1, 
    SDRTxBlock=2, 
    SDRMbBlock=3 } SDRBlockTypeT;

typedef struct _SDRManagerPropsT {
    char           RadioAddress[SDR_MAX_STR_SIZE]; /* "192.168.10.2;192.168.20.2" (or usb id, ...) */
    SDRBlockTypeT  sdrBlockType;                     /* rx, tx, mboard */
    char           requester[SDR_MAX_STR_SIZE];      /* host obj -- for locking identification */
    char           driverLib[SDR_MAX_STR_SIZE];      
    bool           firstDriverForRadio;
} SDRManagerPropsT;

namespace sdr {
  namespace drivers {


class DriverIfT {
  public:

    SDRManagerPropsT mgrProps;

    PluginLoaderPtr pilptr;

    DriverIfT(SDRManagerPropsT props) : mgrProps(props), pilptr(NULL) {;};
    virtual ~DriverIfT() {;};


    virtual void reset(
                    const int32_t resetType, 
                    const int32_t deviceID) 
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void setConfiguration(
                    const int32_t setPropValsSize, 
                    const uint8_t * const setPropVals) 
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void getConfiguration(
                    const int32_t propListToGetSize, 
                    const uint8_t * const propListToGet, 
                    int32_t * const actualPropValsSize,
                    uint8_t * const actualPropVals) 
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

	/* DEBUG METHOD */
	virtual void writeAddress(
                    const uint32_t addr,
                    const uint32_t wlen,
                    const uint32_t winc,
                    const uint32_t dwlen,
                    const uint8_t* const data)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };


    virtual void readAddress(
                    const uint32_t addr,
                    const uint32_t wlen,
                    const uint32_t winc,
                    uint32_t* const dwlen,
                    uint8_t* const data)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };


    virtual void testLoopback(
                    const uint32_t len,
                    const uint8_t* const data,
                    uint32_t* const rlen,
                    uint8_t* const rdata)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void testCheckPattern(
                    const uint32_t len,
                    const uint32_t patID)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void testGeneratePattern(
                    const uint32_t len,
                    const uint32_t patID)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void setProperty(
                    const uint32_t propId,
                    const uint32_t  propLen,
                    const uint8_t * const propVal)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void getProperty(
                    const uint32_t  propId,
                    uint32_t * const propLen,
                    uint8_t * const propVal)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    /* SYSTEM OBJECT */
    virtual void infoImpl(
                    char (* const infoStr))
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void setupImpl(
                    const int32_t nonTunablePropsSize,
                    const uint8_t * const nonTunableProps, 
                    const int32_t tunablePropsSize,
                    const uint8_t * const tunableProps)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void releaseImpl()
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void processTunedPropertiesImpl(
                    const int32_t setPropValsSize,
                    const uint8_t * const setPropVals)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void rxStepImpl(
                    int32_t * const sampleDataSize, 
                    uint8_t * const sampleData, 
                    int32_t * const sampleMetaDataSize,
                    uint8_t * const sampleMetaData)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };
    

    virtual void txStepImpl(
                    const int32_t sampleDataSize, 
                    const uint8_t * const sampleData, 
                    int32_t * const sampleMetaDataSize,
                    uint8_t * const sampleMetaData)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual void txStepImplVoid(
                    const int32_t sampleDataSize, 
                    const void * const sampleData, 
                    int32_t * const sampleMetaDataSize,
                    uint8_t * const sampleMetaData)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };
};

// --------------------
// PLUG IN HOOK POINTS
// --------------------
typedef boost::shared_ptr<sdr::drivers::DriverIfT> DriverIfSptrT;

static const char * const FIND_RADIOS_FCN = "sdr_plugin_findRadios";
typedef std::string (*FindRadiosFcn)(void);

static const char * const CREATE_DRIVER_FCN = "sdr_plugin_createSDRDriver";
//typedef sdr::drivers::DriverIfSptrT (*CreateSDRDriverFcn)(
typedef void (*CreateSDRDriverFcn)(
        SDRManagerPropsT props,
        const int32_t creationArgsSize, const uint8_t * const creationArgs,
        sdr::drivers::DriverIfT **driver);


 }; // end namespace drivers
}; // end namespace sdr


#endif // end header lock

