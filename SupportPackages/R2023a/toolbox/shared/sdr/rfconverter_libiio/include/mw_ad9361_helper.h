/* mw_ad9361_helper.h
 *
 * Copyright 2018 The MathWorks, Inc. 
 */

#ifndef __MW_AD9361_HELPER__
#define __MW_AD9361_HELPER__
#include "iio_helper.h"

/* public fucntions */
// Wrap base poll functions 
int mw_ad9361_setup_poll(struct mw_iio_poll_config *poll_config, struct iio_buffer *buf, double timeout, int isOutput);
int mw_ad9361_poll(struct mw_iio_poll_config *poll_config);
int mw_ad9361_scheduler_poll();
int mw_ad9361_signal();
int mw_ad9361_wait();
// Filter setup functions
int mw_ad9361_getFilterStr(int filtDecimInterpFactor, int filtGain, int filtCoefficients[128], int filtCoefficientSize, char *filterStr); 
int mw_ad9361_getFilterStrBoth(int filtDecimInterpFactor, int filtCoefficients[128], int filtCoefficientSize, int filtGain, int OtherFiltDecimInterpFactor, int OtherFiltCoefficients[128], int OtherFiltGain, int isTx, char *filterStr);

#endif /* __MW_AD9361_HELPER__ */
