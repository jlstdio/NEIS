
#ifndef __sdrglobal_defs_h__
#define __sdrglobal_defs_h__

/* Thinking this file will be used to hold types that span the layers. */

/* This type is used in TxDataDeviceT in sdrdatapath but is passed as a type by its caller
 * in sdrembed.  Not sure exactly where it belongs.
 *
 * 1. add it to SDREmbedPropsT (meaning it is unpacked in sdrembed/sdr_devices.cpp)
 * 2. create SDRDatapathPropsT and put it there (meaning unpacked in sdrdatapath/sdr_datapath.cpp)
 * 3. do something else with it.
 *
 * I'm putting it in here until I can refactor the code.
 */
typedef enum {
    DPortDTypeInt16=0,
    DPortDTypeSingle,
    DPortDTypeDouble,
    DPortDTypeCInt16,
    DPortDTypeCSingle,
    DPortDTypeCDouble
} SDRDPortDTypeT;

#endif
