/* Copyright 2017-2018 The MathWorks, Inc. */
#include "iio.h"
#include "iio_helper.h"

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#elif defined(__APPLE__)
#include <mach/mach.h>
#include <mach/mach_time.h>
#endif

/******************************************************************************/
/************************ Inline Functions *******************************/
/******************************************************************************/

/***************************************************************************//**
 * @brief timespec_normalize
*******************************************************************************/
static inline void timespec_normalize(struct timespec *ts)
{
	// normalize
	while(ts->tv_nsec >= 1000*1000*1000){
		ts->tv_sec++;
		ts->tv_nsec -= 1000*1000*1000;
	}
}

/***************************************************************************//**
 * @brief dbl_to_timespec
*******************************************************************************/
static inline void dbl_to_timespec(struct timespec *ts, double sec)
{
#if defined(__linux__)
	// convert to nanoseconds
	ts->tv_sec = (__time_t)(sec);
	ts->tv_nsec = (__syscall_slong_t)((sec*1.0E9) - ((double)ts->tv_sec*1.0E9));
#elif defined(__APPLE__)
	// convert to nanoseconds
	ts->tv_sec = (long int)(sec);
	ts->tv_nsec = (long int)((sec*1.0E9) - ((double)ts->tv_sec*1.0E9));
#endif //defined(__linux__)
	//Normalize
	timespec_normalize(ts);
}

/***************************************************************************//**
 * @brief timespec_to_dbl
*******************************************************************************/
static inline double timespec_to_dbl(struct timespec *ts)
{
	//Normalize
    timespec_normalize(ts);
    // convert to seconds
    return ((double)ts->tv_sec) + ((double)ts->tv_nsec/1.0E9);
}

/******************************************************************************/
/************************ Public Functions *******************************/
/******************************************************************************/

/***************************************************************************//**
 * @brief mw_gettime
*******************************************************************************/
double mw_gettime()
{
#if defined(__linux__)
    struct timespec ts;

    clock_gettime(CLOCK_MONOTONIC, &ts);
    return timespec_to_dbl(&ts);
#elif defined(__APPLE__)
    mach_timebase_info_data_t sTimebaseInfo;
    static double ns_per_tick;

    // We only need to get timebase information once
    if (ns_per_tick == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }

    // Each tick lasts ns_per_tick ns
    ns_per_tick = ((double)sTimebaseInfo.numer/(double)sTimebaseInfo.denom); 
    // Get time in seconds, scale absolute time to avoid overflows in multiplication
    return ((double)mach_absolute_time()/1e9)*ns_per_tick;
#elif defined(_WIN32) || defined(_WIN64)
    static LARGE_INTEGER freq;
    LARGE_INTEGER count;
    
    // We only need to get the clock frequency once
    if (freq.QuadPart == 0)
    {
        QueryPerformanceFrequency((LARGE_INTEGER *) &freq);
    }

    if(QueryPerformanceCounter((LARGE_INTEGER *) &count) == 0)
    {
        return 0;
    }
    return ((double)count.QuadPart/(double)freq.QuadPart);
#endif
}

/***************************************************************************//**
 * @brief mw_iio_setup_poll
*******************************************************************************/
int mw_iio_setup_poll(struct mw_iio_poll_config *poll_config, struct iio_buffer *buf, double timeout, int isOutput)
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
	if (!buf){
		return -EINVAL;
	}
	if (timeout >= 0.0){
		dbl_to_timespec(&poll_config->pollTS, timeout);
		poll_config->isTimeoutInf = 0;
	} else {
		poll_config->isTimeoutInf = 1;
	}
	if(isOutput) {
		poll_config->pollfd.events = POLLOUT;
	} else {
		poll_config->pollfd.events = POLLIN;
	}
	
	poll_config->pollfd.fd = iio_buffer_get_poll_fd(buf);
	if (poll_config->pollfd.fd < 0) {
		return poll_config->pollfd.fd;
	}
	return 0;
#else 
    return 0;
#endif //!(defined(MATLAB_MEX_FILE) || defined(NRT))|| defined(MATLAB_RACCEL))
}

/***************************************************************************//**
 * @brief mw_iio_setup_poll_and_get_config
*******************************************************************************/
void * mw_iio_setup_poll_and_get_config(struct mw_iio_poll_config *poll_config, struct iio_buffer *buf, double timeout, int isOutput) {
    mw_iio_setup_poll(poll_config, buf, timeout, isOutput);
    return ((void*) poll_config);
}
        
/***************************************************************************//**
 * @brief mw_iio_poll
*******************************************************************************/
int mw_iio_poll(struct mw_iio_poll_config *poll_config)
{
#if !(defined(MATLAB_MEX_FILE) || defined(NRT) || defined(MATLAB_RACCEL))
	int status;
	struct timespec *ts;
	
	poll_config->pollfd.revents = 0x0;

	if (poll_config->isTimeoutInf) {
		ts = NULL;
	} else {
		ts = &poll_config->pollTS;
	}
	
	status = ppoll(&poll_config->pollfd,1,ts, NULL);

	if (status < 0) {
		/* Got an error code */
		return status;
	} else if (status == 0) {
		/* Timed out */
		return -ETIMEDOUT;
	} else if (!(poll_config->pollfd.events & poll_config->pollfd.revents)) {
		/* Got an event, but not one we were waiting for */
		return -EFAULT;
	} else {
		return 0;
	}
#else 
    return 0;
#endif //!(defined(MATLAB_MEX_FILE) || defined(NRT))|| defined(MATLAB_RACCEL))
}
