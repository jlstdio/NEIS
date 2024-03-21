#ifdef _POLL_DRIVEN_BASERATE_	 //Use polling events to drive baserate

#include <MW_poll_event_init.h>

poll_info pollInfo;
#endif
int setup_poll_info(void)
{
    int fd = -1;

#ifdef _POLL_DRIVEN_BASERATE_	 //Use polling events to drive baserate    
    /* Find the file we want to poll on */
    find_polling_descriptor(&pollInfo, POLL_SEARCH_PATH, POLL_FILE_NAME);

    /* Set up the descriptor for polling */
#ifdef POLL_BASERATE_TIMEOUT	 
    /* Set timeout values to configured timeout from block */
    fd = setup_polling_descriptor(&pollInfo, POLL_BASERATE_TIMEOUT, POLLPRI|POLLERR, POLL_INITIAL_TICKS_COUNT, POLL_ERROR_ON_TIMEOUT);
#else
    /* Blocking */
    fd = setup_polling_descriptor(&pollInfo, -1, POLLPRI|POLLERR, POLL_INITIAL_TICKS_COUNT,POLL_ERROR_ON_TIMEOUT);
#endif

#endif
    return fd;
}
