/*
 * iio helper - helper functions
 *
 * Copyright 2016-2018 The MathWorks, Inc.
 *
 * */

#ifndef __IIO_HELPER__
#define __IIO_HELPER__

#include "iio.h"
#include <errno.h>
#include <time.h>
#include <stdint.h>

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#endif

#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
#include <poll.h>	
#endif


/******************************************************************************/
/************************ Macros *******************************/
/******************************************************************************/
#define	EPS		1.0E-6


/******************************************************************************/
/************************ Structs *******************************/
/******************************************************************************/

struct mw_iio_poll_config {
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
	struct timespec pollTS;
	struct pollfd pollfd;
#endif
	int isTimeoutInf;
};

/******************************************************************************/
/************************ Inline Functions *******************************/
/******************************************************************************/

/*****************************************************************************
 * @brief check_pointer
*******************************************************************************/
static inline int check_pointer(void *ptr){
    if (!ptr)
        return -ENODEV;
    else
        return 0;
}

/*****************************************************************************
 * @brief dbl_to_s32
*******************************************************************************/
static inline int32_t dbl_to_s32(double in){
	if (in > 0.0)
		return (int32_t)(in+EPS);
	else
		return (int32_t)(in-EPS);
}

/*****************************************************************************
 * @brief dbl_to_u32
*******************************************************************************/
static inline uint32_t dbl_to_u32(double in){
	return (uint32_t)(in+EPS);
}

/*****************************************************************************
 * @brief dbl_to_u64
*******************************************************************************/
static inline uint64_t dbl_to_u64(double in){
	return (uint64_t)(in+EPS);
}

/*****************************************************************************
 * @brief dbl_to_s64
*******************************************************************************/
static inline int64_t dbl_to_s64(double in){
	return (int64_t)(in+EPS);
}

/******************************************************************************/
/************************ Constants *******************************/
/******************************************************************************/

static const struct mw_iio_poll_config EmptyPollConfig = {0};

/******************************************************************************/
/************************ Public Functions *******************************/
/******************************************************************************/
extern int mw_iio_setup_poll(struct mw_iio_poll_config *poll_config, struct iio_buffer *buf, double timeout, int isOutput);
extern void * mw_iio_setup_poll_and_get_config(struct mw_iio_poll_config *poll_config, struct iio_buffer *buf, double timeout, int isOutput);
extern int mw_iio_poll(struct mw_iio_poll_config *poll_config);
extern double mw_gettime();


#endif
