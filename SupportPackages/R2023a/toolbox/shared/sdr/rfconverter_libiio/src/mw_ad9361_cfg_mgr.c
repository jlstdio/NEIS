#include <string.h>
#include "mw_ad9361_cfg_mgr.h"

static mw_ad9361_configdata TxConfigData = { .isValid = 0};
static mw_ad9361_configdata RxConfigData = { .isValid = 0};

// Track Tx/RX Config settings
// devID, isTx, infoType, info
void mw_ad9361_setConfigData(char *devID, int isTx, mw_ad9361_configdata *data) {	
	mw_ad9361_configdata *tgt;
	
	if (isTx) {
		tgt = &TxConfigData;
	} else {
		tgt = &RxConfigData;
	}
	memcpy(tgt, data, sizeof(mw_ad9361_configdata));
}

void mw_ad9361_getConfigData(char *devID, int isTx, mw_ad9361_configdata *data) {	
	mw_ad9361_configdata *src;
	if (isTx) {
		src = &TxConfigData;
	} else {
		src = &RxConfigData;
		
	}
	memcpy(data, src, sizeof(mw_ad9361_configdata));
}
