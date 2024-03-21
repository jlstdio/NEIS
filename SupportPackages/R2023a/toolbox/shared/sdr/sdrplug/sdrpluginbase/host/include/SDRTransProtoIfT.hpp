#ifndef __SDRTransProtoIfT_hpp__
#define __SDRTransProtoIfT_hpp__

#include <sdrtransports/sdr_transports.hpp>
#include <sdrutils/sdr_exception.hpp> // MWErrIDException

namespace sdr {
    namespace protocols {

/* ------------ CONTROL arg types --------------- */
typedef uint32_t DevId_T;
typedef uint32_t PatId_T;
typedef uint32_t PropId_T;
typedef uint32_t ActionId_T;

static const DevId_T    FPGA_DEV	  = 0x00;
static const DevId_T    RXFPGA_DEV	  = 0x01;
static const DevId_T    TXFPGA_DEV	  = 0x02;
static const DevId_T    RFBOARD_DEV	  = 0x03;
static const DevId_T    RXRFBOARD_DEV = 0x04;
static const DevId_T    TXRFBOARD_DEV = 0x05;

static const DevId_T    RXDUT_DEV	  = 0x06;
static const DevId_T    TXDUT_DEV	  = 0x07;

static const DevId_T    RXHWBURST_DEV = 0x11;
static const DevId_T    TXHWBURST_DEV =	0x12;

static const DevId_T    PROTO_VER	= 0x100;
static const DevId_T    FIRM_VER	= 0x101;

static const uint32_t   LIST_VER_SIZE = 8;

static const DevId_T    LIST_VER[LIST_VER_SIZE]=
                            {PROTO_VER, FIRM_VER,
                            FPGA_DEV, RXFPGA_DEV, TXFPGA_DEV,
                            RFBOARD_DEV, RXRFBOARD_DEV, TXRFBOARD_DEV};


static const std::string STRING_VER[LIST_VER_SIZE]=
    {"hw.ProtocolVersion", "hw.FirmwareVersion",
    "hw.HardwareVersion", "hw.HardwareRxCapabilities", "hw.HardwareTxCapabilities",
    "hw.RFBoardVersion", "hw.RFBoardRxCapabilities", "hw.RFBoardTxCapabilities"};

static const uint32_t   COMPATIBILITY_VER_LIST_SIZE = 3;

static const std::string COMPATIBILITY_VER_LIST[COMPATIBILITY_VER_LIST_SIZE]=
    {"%u.%u.%u", "%u.%u.%u","%u.%u.%u"};

static const PatId_T    ONEZEROTOGGLE0_8_ID     = 0x00;
static const PatId_T    ONEZEROTOGGLE1_8_ID		= 0x01;
static const PatId_T    ONEZEROTOGGLE0_16_ID    = 0x02;
static const PatId_T    ONEZEROTOGGLE1_16_ID	= 0x03;
static const PatId_T    ONEZEROTOGGLE0_32_ID	= 0x04;
static const PatId_T    ONEZEROTOGGLE1_32_ID	= 0x05;
static const PatId_T    CHECKERBOARD0_ID		= 0x10;
static const PatId_T    CHECKERBOARD1_ID	 	= 0x11;

/* ------------ DATA arg types --------------- */
typedef uint8_t DataProtocolSampleT;

typedef std::vector<DataProtocolSampleT> DataProtocolSampleBufferT;
typedef struct
{
    bool overflow;
    bool high;
    bool medium;
    bool low;
    bool underflow;
}DataProtocolBufferStatusT;
typedef struct
{
    uint32_t RXDATA_DATA_NUM;
    uint32_t RXDATA_DATA_SIZE;
    uint32_t RXDATA_PKT_SIZE;

    uint32_t TXDATA_DATA_NUM;
    uint32_t TXDATA_DATA_SIZE;
    uint32_t TXDATA_PKT_SIZE;

    uint32_t TXSTREAMDATA_DATA_NUM;
    uint32_t TXSTREAMDATA_DATA_SIZE;
    uint32_t TXSTREAMDATA_PKT_SIZE;
} PacketSizeInfoT;

/* ----------- PROTO INTERFACE ---------- */
class SDRTransProtoIfT {
    public:

    typedef boost::shared_ptr<SDRTransProtoIfT> SptrT;

    SDRTransProtoIfT() { ; }
    virtual ~SDRTransProtoIfT() {;};

    /* ------------ CONTROL IF --------------- */
     virtual int32_t HardReset(
                    const DevId_T  devId) 
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };


    virtual int32_t SoftReset(
                    const DevId_T  devId) 
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t GetVersion(
                    const DevId_T  devId,
                    std::string & verStr)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t TestLoopback(
                    const uint32_t len,
                    const uint8_t* const data,
                    uint32_t* const rlen,
                    uint8_t* const rdata)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t TestCheckPattern(
                    const uint32_t len,
                    const PatId_T pat)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t TestGeneratePattern(
                    const uint32_t len,
                    const PatId_T pat)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t WriteAddress(
                    const uint32_t addr,
                    const uint32_t inc,
                    const uint32_t wlen,
                    const uint32_t len,
                    const uint8_t* const data)

    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t ReadAddress(
                    const uint32_t addr,
                    const uint32_t inc,
                    const uint32_t wlen,
                    uint32_t* const len,
                    uint8_t* const data)

    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t SetProperty(
                    const PropId_T propId,
                    const uint32_t  propLen,
                    const uint8_t * const propVal)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t GetProperty(
                    const PropId_T  propId,
                    uint32_t * const propLen,
                    uint8_t * const propVal)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t InitAction(
                    const DevId_T  devId)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t EnableAction(
                    const DevId_T  devId)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    virtual int32_t DisableAction(
                    const DevId_T  devId)
    { 
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    };

    /* ------------ DATA IF --------------- */
    virtual void receiveDataPacket(DataProtocolSampleBufferT & sampleBuf, int32_t & samplesRead, 
                           uint16_t & sequenceNumber, uint16_t & hwStatus)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    }

    virtual void transmitStreamDataPacket(sdr::protocols::DataProtocolSampleBufferT & sampleBuf, int32_t samplesWrite, uint32_t seq, bool sot, bool eot)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    }

    virtual void transmitDataPacket(DataProtocolSampleBufferT & sampleBuf, int32_t samplesWrite, uint32_t interpolationFactor)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    }

    virtual void sendNopPacket(void)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    }

    virtual bool receiveBufferStatus(DataProtocolBufferStatusT & bufferStatus)
    {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    }

    virtual PacketSizeInfoT setSampleSize(size_t sampleSize) {
        throw(MWErrIDException("DriverNoDefaultImpl", "")); 
    }

    private:

};

    }; // namespace protocols
}; // namespace sdr

#endif
