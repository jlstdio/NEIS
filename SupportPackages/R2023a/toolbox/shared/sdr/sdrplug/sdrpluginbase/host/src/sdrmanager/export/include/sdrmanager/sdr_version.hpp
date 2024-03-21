/* This file single sources SDR versioning information placed into the HW Info
 * registers and into the SW in the driver library.
 *
 * The HW info registers are defined in SDRBuildInfo and versioning will be
 * determined by parsing this file looking for the SDR_HW.XXX field definitions in
 * the C-code comments.
 *
 * The SW version is defined directly by this header file.
 *
 * SW/HW compatibility is determined in sdrf.cpp.
 *
 * Encodings of version fields are in SDRHWInfoRegistersT.m.
 *
 * Decodings of version fields are in fpga_devices.hpp/.cpp.
 *
 * Most field encoding/decodings here are straight-forward.  The MATLAB release
 * is bit[7]=0 => 'A' release,  1 => 'B' release.  So...
 * R2012b = 12 | SDR_SW_REVB
 * R2013a = 13 | SDR_SW_REVA
 * R2013b = 13 | SDR_SW_REVB
 * R2014a = 14 | SDR_SW_REVA
 * R2014b = 14 | SDR_SW_REVB
 */

/* Copyright 2012 The MathWorks, Inc. */

#ifndef __sdr_version_hpp__
#define __sdr_version_hpp__

#include "libmwsdrmanager.hpp"
#include <stdint.h>

/* FOR USE BY MATLAB FOR HW VERSIONING 
 * THIS CODE WILL BE EVAL'ED IN MATLAB.
 * Keep as a COMMENT since this is included by C++.
*/
/*
BEGIN_MATLAB_VERSIONING
SDR_HW.major         = 10;
SDR_HW.minor         = 0;
SDR_HW.build         = 0;
END_MATLAB_VERSIONING
*/

/* These major version numbers are compared against the equivalent
   in ESW.
   Protocol version and firmware version are stored in protocol_version.c.
   Hardware version is stored in misc_driver.c.
*/
static const uint8_t SDR_PROTOCOL_VER_MAJOR	= 10;
static const uint8_t SDR_PROTOCOL_VER_MINOR	= 0;
static const uint8_t SDR_PROTOCOL_VER_BUILD	= 0;

static const uint8_t SDR_FIRMWARE_VER_MAJOR = 10;
static const uint8_t SDR_FIRMWARE_VER_MINOR = 0;
static const uint8_t SDR_FIRMWARE_VER_BUILD = 0;

static const uint8_t SDR_FPGA_HARDWARE_VER_MAJOR = 10;
static const uint8_t SDR_FPGA_HARDWARE_VER_MINOR = 0;
static const uint8_t SDR_FPGA_HARDWARE_VER_BUILD = 0;

static const uint8_t SDR_VERSION_LIST[3] = {SDR_PROTOCOL_VER_MAJOR,
											SDR_FIRMWARE_VER_MAJOR,
											SDR_FPGA_HARDWARE_VER_MAJOR};
                                            
/* ##########################################################

    DON'T FORGET TO UPDATE THE MATLAB VERSIONING ABOVE!!
    
########################################################## */

#endif //__sdr_version_hpp__

