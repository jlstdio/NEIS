/* 
 * Copyright 2018 The MathWorks, Inc. 
*/

#include "mw_ad9361_helper.h"
#include <stdio.h>

#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))

#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

/* Locally scoped variables to track the transmit and receive path */
static struct mw_iio_poll_config *mw_ad9361_rx_poll_config = NULL;
static struct mw_iio_poll_config *mw_ad9361_tx_poll_config = NULL;
static sem_t mw_ad9361_rx_sem;
static sem_t mw_ad9361_tx_sem;
#endif // !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))

/**
 * @brief mw_ad9361_setup_poll
 *
 * This function wraps the mw_iio_setup_poll function and modifes the incoming
 * values to be suitable for interrupt support for libiio SDR
 *
 */
int mw_ad9361_setup_poll(struct mw_iio_poll_config *poll_config, struct iio_buffer *buf, double timeout, int isOutput)
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))

    /* Assign the static variable for use in HW/SW co-design.
     * Change timeout to negative value to enabled infinite waiting for the device
     * of interest
     * */
    if (isOutput) {
#if defined(__MW_SDR_TX_INTERRUPT__)
        timeout = -1;
        sem_init(&mw_ad9361_tx_sem,0,0);
#endif
        mw_ad9361_tx_poll_config = poll_config;
    } else {
#if defined(__MW_SDR_RX_INTERRUPT__)
        timeout = -1;
        sem_init(&mw_ad9361_rx_sem,0,0);
#endif
        mw_ad9361_rx_poll_config = poll_config;
    }
#endif // !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
    return mw_iio_setup_poll(poll_config, buf, timeout, isOutput);
}
/**
 * @brief mw_ad9361_poll
 *
 * Wraps mw_iio_poll and tests whether interrupt mode is enabled to avoid
 * double polling on the same file descriptor from mw_ad9361_scheduler_poll
 */
int mw_ad9361_poll(struct mw_iio_poll_config *poll_config)
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
#if defined(__MW_SDR_TX_INTERRUPT__)
    if (POLLOUT == poll_config->pollfd.events)
    {
        return 0;
    }
#endif
#if defined(__MW_SDR_RX_INTERRUPT__)
    if (POLLIN == poll_config->pollfd.events)
    {
        return 0;
    }
#endif
#endif // !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
    return mw_iio_poll(poll_config);
}

/**
 * @brief mw_ad9361_scheduler_poll
 *
 * Used by the scheduler to poll on the libiio file descriptor to drive the
 * model base rate
 */
int mw_ad9361_scheduler_poll()
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
#if defined(__MW_SDR_TX_INTERRUPT__)
    return mw_iio_poll(mw_ad9361_tx_poll_config);
#endif
#if defined(__MW_SDR_RX_INTERRUPT__)
    return mw_iio_poll(mw_ad9361_rx_poll_config);
#endif
    puts("No interrupt mode specified");
#endif // !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
    return 0;
}

int mw_ad9361_signal()
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
#if defined(__MW_SDR_TX_INTERRUPT__)
    sem_post(&mw_ad9361_tx_sem);
#endif
#if defined(__MW_SDR_RX_INTERRUPT__)
    sem_post(&mw_ad9361_rx_sem);
#endif
#endif // !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
    return 0;
}

int mw_ad9361_wait()
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
#if defined(__MW_SDR_TX_INTERRUPT__)
    sem_wait(&mw_ad9361_tx_sem);
#endif
#if defined(__MW_SDR_RX_INTERRUPT__)
    sem_wait(&mw_ad9361_rx_sem);
#endif
#endif // !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
    return 0;
}

#define FIR_BUF_SIZE 8192

int mw_ad9361_getFilterStr(int filtDecimInterpFactor, int filtGain, int *filtCoefficients, int filtCoefficientSize, char *filterStr) //, int *numChars)
{
    int len = 0;
    int i;
    
    if (!filterStr)
        return -ENOMEM;

    // Make Rx and Tx filter strings the same
    len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "RX 3 GAIN %d DEC %d\n", filtGain, filtDecimInterpFactor);
    len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "TX 3 GAIN %d INT %d\n", filtGain, filtDecimInterpFactor);

    // Filter coefficients are the same for Tx and Rx
    for (i = 0; i < filtCoefficientSize; i++)
        len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "%d,%d\n", filtCoefficients[i], filtCoefficients[i]);

    // Finish with a newline
    len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "\n");
    
    return 0;
}

int mw_ad9361_getFilterStrBoth(int filtDecimInterpFactor, int filtCoefficients[128], int filtCoefficientSize,
                                int filtGain, int OtherFiltDecimInterpFactor, int OtherFiltCoefficients[128],
                                int OtherFiltGain, int isTx, char *filterStr)
{
    int len = 0;
    int i;
    
    if (!filterStr)
        return -ENOMEM;
    
    if (isTx!=0) {
        // Rx filter string
        len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "RX 3 GAIN %d DEC %d\n", OtherFiltGain, OtherFiltDecimInterpFactor);
        // Tx filter string
        len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "TX 3 GAIN %d INT %d\n", filtGain, filtDecimInterpFactor);

        // Tx filters come in first column https://wiki.analog.com/resources/tools-software/linux-drivers/iio-transceiver/ad9361#load_a_filter
        for (i = 0; i < filtCoefficientSize; i++)
            len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "%d,%d\n", OtherFiltCoefficients[i], filtCoefficients[i]);         
        
    } else {
        // Rx filter string
        len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "RX 3 GAIN %d DEC %d\n", filtGain, filtDecimInterpFactor);
        // Tx filter string
        len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "TX 3 GAIN %d INT %d\n", OtherFiltGain, OtherFiltDecimInterpFactor);

        // Tx filters come in first column https://wiki.analog.com/resources/tools-software/linux-drivers/iio-transceiver/ad9361#load_a_filter
        for (i = 0; i < filtCoefficientSize; i++)
            len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "%d,%d\n", filtCoefficients[i], OtherFiltCoefficients[i]); 
    }
    // Finish with a newline
    len += snprintf(filterStr + len, FIR_BUF_SIZE - len, "\n");    
    
    return 0;
}
