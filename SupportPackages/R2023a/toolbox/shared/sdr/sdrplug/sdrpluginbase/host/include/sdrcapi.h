/* Copyright 2014-2015 The MathWorks, Inc. */
/* 
 * C-API for SDR host drivers
 *
 */
#ifndef __sdrcapi_h__
#define __sdrcapi_h__

#include "sdrcapi_types.h"
/* #include "tmwtypes.h" */
#include <stdint.h>
#include "libmwsdrmanager.hpp"
#define ERR_ARGS SDRPluginStatusT * errStat, char (* const errId), char (* const errStr)
/* --------------------- driver management --------------------- */
LIBMWSDRMANAGER_API_EXTERN_C void findRadios_c (
    const int32_t findArgsSize,
    const uint8_t * const findArgs, 
    char (* const foundRadioAddresses), 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void createDriver_c (
    const int32_t creationArgsSize,
    const uint8_t * const creationArgs , 
    int32_t  * const driverHandle,
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void reportDrivers_c (
    char (* const radioAddresses), 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void deleteDriver_c (
    const int32_t driverHandle, 
    ERR_ARGS);


/* ----------------- interactive actions ------------------------- */

/* --------- SYNCHRONIZE BUTTON/METHOD --------------- */
LIBMWSDRMANAGER_API_EXTERN_C void setConfiguration_c (
    const int32_t driverHandle, 
    const int32_t setPropValsSize,
    const uint8_t * const setPropVals, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void getConfiguration_c (
    const int32_t driverHandle, 
    const int32_t propListToGetSize,
    const uint8_t * const propListToGet, 
    int32_t * const actualPropValsSize,
    uint8_t * const actualPropVals, 
    ERR_ARGS);

/* --------- DEBUG METHOD --------------- */
LIBMWSDRMANAGER_API_EXTERN_C void writeAddress_c(
				const int32_t driverHandle,
                const uint32_t addr,
                const uint32_t wlen,
                const uint32_t winc,
                const uint32_t dwlen,
                const uint8_t* const data,
				ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void readAddress_c(
				const int32_t driverHandle,
                const uint32_t addr,
                const uint32_t wlen,
                const uint32_t winc,
                uint32_t* const dwlen,
                uint8_t* const data,
				ERR_ARGS);


LIBMWSDRMANAGER_API_EXTERN_C void testLoopback_c(
					const int32_t driverHandle,
                    const uint32_t len,
                    const uint8_t* const data,
                    uint32_t* const rlen,
                    uint8_t* const rdata,
					ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void testCheckPattern_c(
					const int32_t driverHandle,
                    const uint32_t len,
                    const uint32_t patID,
					ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void testGeneratePattern_c(
					const int32_t driverHandle,
                    const uint32_t len,
                    const uint32_t patID,
					ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void setProperty_c(
					const int32_t driverHandle,
                    const uint32_t propId,
                    const uint32_t  propLen,
                    const uint8_t * const propVal,
					ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void getProperty_c(
					const int32_t driverHandle,
                    const uint32_t  propId,
                    uint32_t * const propLen,
                    uint8_t * const propVal,
					ERR_ARGS);


/* --------  RESET BUTTON/METHOD ----------- */
/* Do not believe this will follow System object semantics.  For a sys obj, the
 * resetImpl is called as last part of setup() call.  This doesn't jive with
 * using reset for board state since one would have set up a bunch of properties
 * only to have them clobbered.  Indeed, resetImpl will just be a local sys obj
 * method.  This is reserved as a special action.
 */
LIBMWSDRMANAGER_API_EXTERN_C void reset_c (
    const int32_t driverHandle, 
	const int32_t resetType,
    const int32_t deviceID,
    ERR_ARGS);

/* ----------- INFO BUTTON/METHOD --------- */
/* see sysobj entrypoint infoImpl_c */

/* ----------------- System object run-time methods ----------------------- */
/* ---------------------------------------------------
 * FULL CALLING STACKS FOR SYSOBJ METHODS:
 * ---------------------------------------------------
 * info :
 *      infoImpl                : YES in CAPI
 * setup:
 *      validatePropertiesImpl  : local to sys obj
 *      validate inputs         : sys obj built-in
 *      cache input specs       : sys obj built-in
 *      validateInputsImpl      : local to sys obj
 *      setupImpl               : YES in CAPI
 *      lock object             : sys obj built-in
 *      resetImpl               : local to sys obj
 * step:
 *      validate num ins/outs
 *      if !setup
 *          releaseImpl
 *          setup (see above)
 *      else
 *          validatePropertiesImpl : local to sys obj
 *          processTunedPropertiesImpl : YES in CAPI
 *      stepImpl
 * reset:
 *      resetImpl               : local to sys obj
 * release:
 *      releaseImpl             : YES in CAPI
 *
 * other DOCUMENTED impl methods (top caller not given) NOT IN CAPI:
 *  Basic Opertaions:
 *      setProperties
 *      getNumInputsImpl
 *      getNumOutputsImpl
 *      isDoneImpl
 *  Properties and states:
 *      isInactivePropertyImpl
 *      getDiscreteStateImpl
 *  Load and save:
 *      cloneImpl
 *      saveObjectImpl
 *      loadObjectImpl
 *
 *  SYSTEM BLOCK SIMULINK INTEGRATION:
 *  Icon and dialog:
 *      getIconImpl
 *      getHeaderImpl
 *      getInputNamesImpl
 *      getOutputNamesImpl
 *      getPropertyGroupsImpl
 *  Input specs:
 *      isInputSizeMutableImpl
 *      isInputComplexityMutableImpl
 *      processInputSpecificationChangeImpl
 *  Output specs:
 *      getOutputSizeImpl
 *      getOutputDataTypeImpl
 *      isOutputComplexImpl
 *      isOutputFixedSizeImpl
 *      getDiscreteStateSpecificationImpl
 *      propagatedInputComplexity
 *      propagatedInputDataType
 *      propagateInputFixedSize
 *      propagateInputSize
 *   Nondirect feedthrough:
 *      isInputDirectFeedthroughImpl
 *      outputImpl
 *      updateImpl
 *
 * other UNDOCUMENTED impl methods I saw in a metaclass query NOT in CAPI:
 *  setDiscreteStateImpl
 *  getContinuousStateImpl
 *  setContinuousStateImpl
 *  canAccelerateImpl
 *  supportsMultipleInstanceImpl
 *  getDisplayFixedPointPropertiesImpl
 *  getDisplayPropertiesImpl
 *
 *
 *
 * ---------------------------------------------------
 * SUMMARY OF SYSOBJ METHODS IN CAPI:
 * ---------------------------------------------------
 * NOTE: we do not support any varargs in stepImpl call
 * info     --> infoImpl
 * setup    --> setupImpl
 * step     --> if !setup: releaseImpl, setupImpl
 *              else     : processTunedProperties
 *              stepImpl
 * release  --> releaseImpl
 */

LIBMWSDRMANAGER_API_EXTERN_C void infoImpl_c (
    const int32_t driverHandle, 
    char (* const infoStr), 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void setupImpl_c (
    const int32_t creationArgsSize,
    const uint8_t * const creationArgs, 
    const int32_t nonTunablePropsSize,
    const uint8_t * const nonTunableProps, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps, 
    int32_t  * const driverHandle,
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void releaseImpl_c (
    const int32_t driverHandle, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void processTunedPropertiesImpl_c (
    const int32_t driverHandle, 
    const int32_t setPropValsSize,
    const uint8_t * const setPropVals, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void rxStepImpl_c (
    const int32_t driverHandle, 
    int32_t * const sampleDataSize, 
    uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void txStepImpl_c (
    const int32_t driverHandle, 
    const int32_t sampleDataSize, 
    const uint8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void txStepImplVoid_c (
    const int32_t driverHandle, 
    const int32_t sampleDataSize, 
    const void * const sampleData, 
    int32_t * const sampleMetaDataSize,
    uint8_t * const sampleMetaData, 
    ERR_ARGS);


/* ----------------- Simulink block run-time methods ----------------------- */
/* ---------------------------------------------------
 * SUMMARY OF SIMULINK METHODS IN CAPI:
 * ---------------------------------------------------
 * NOTE: We are utilizing Legacy Code Tool for sfunction generation.  It allows
 * for the following entry points:
 * mdlInitializedConditions : not implemented
 * mdlStart                 : YES in CAPI
 * mdlOutput                : YES in CAPI
 * mdlTerminate             : YES in CAPI
 */
LIBMWSDRMANAGER_API_EXTERN_C void mdlStart_c (
    int32_t  * const driverHandle,
    const int32_t nonTunablePropsSize,
    const uint8_t * const nonTunableProps, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void rxMdlOutput_c (
    const int32_t driverHandle, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps, 
    uint32_t * const sampleDataSize, 
    int8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    int8_t * const sampleMetaData, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void txMdlOutput_c (
    const int32_t driverHandle, 
    const int32_t tunablePropsSize,
    const uint8_t * const tunableProps, 
    const uint32_t sampleDataSize, 
    const int8_t * const sampleData, 
    int32_t * const sampleMetaDataSize,
    int8_t * const sampleMetaData, 
    ERR_ARGS);

LIBMWSDRMANAGER_API_EXTERN_C void mdlTerminate_c (
    const int32_t driverHandle, 
    ERR_ARGS);

#if defined(__MW_TARGET_USE_HARDWARE_RESOURCES_H__) /* EMBEDDED CODER CODE-GENERATION HOOKS */
#include "sdrz_arm.h"
#endif

#endif

