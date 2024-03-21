/* Copyright 2014 The MathWorks, Inc. */
/* 
 * Types needed on both MATLAB side and C side for proper use of the CAPI/MAPI
 * pipe.
 *
 */
#ifndef __sdrcapi_types_h__
#define __sdrcapi_types_h__

/* FIXME: Remove enum usage due to g1613506
 *typedef enum { SDRDriverError=0, SDRDriverSuccess=1 } SDRPluginStatusT;
 */
typedef int SDRPluginStatusT;
#define SDRDriverError 0
#define SDRDriverSuccess 1


/* FIXME: defined here and sdr_mapiPrivate */
#define SDR_MAX_STR_SIZE     1024
#define SDR_MAX_ERR_STR_SIZE 1024
#define SDR_MAX_DATA_SIZE    1024*300
#define SDR_MAX_CONFIG_SIZE  1024*5

#endif
