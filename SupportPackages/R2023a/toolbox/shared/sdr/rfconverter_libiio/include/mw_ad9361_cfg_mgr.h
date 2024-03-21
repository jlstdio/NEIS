/* mw_ad9361_cfg_mgr.h
 *
 *
 */

#ifndef __MW_AD9361_CFG_MGR_H__
#define __MW_AD9361_CFG_MGR_H__
#include <rtwtypes.h>

typedef struct {
    uint32_T isValid;
    uint32_T BISTLoopback;
    uint32_T ENSMPinControlMode;
	int32_T  filtGain;
    int32_T filtDecimInterpFactor;
    int32_T filtCoefficientSize;
    int32_T filtCoefficients[128];
    real_T  BasebandSampleRate;
	uint32_T BISTTone[4];
	uint32_T BISTPRBS;
    uint32_T isDDSEnabled;
    real_T  DDSTone1Freq[4];
    real_T  DDSTone2Freq[4];
    real_T  DDSTone1Scale[4];
    real_T  DDSTone2Scale[4];
    real_T  TxChannelMapping[4];
} mw_ad9361_configdata;
              
// Track the "other" configuration
void mw_ad9361_setConfigData(char *devID, int isTx, mw_ad9361_configdata *data);
void mw_ad9361_getConfigData(char *devID, int isTx, mw_ad9361_configdata *data);

#endif /* __MW_AD9361_CFG_MGR_H__ */
