/* Copyright 2016 The MathWorks, Inc. */
#ifndef _MW_POLL_EVENT_HEADER_
#define _MW_POLL_EVENT_HEADER_


#include <poll.h>
#include <sys/stat.h>

typedef struct poll_info_ {
    int fd;
    int initialTicksCount; /* When the model sets up the poll source we need to allow dummy events to allow step calls */
    struct pollfd fdset[1];
    struct timespec *timeout;
    int errorOnTimeout;
    char *fdPath;
} poll_info;

int setup_polling_descriptor(poll_info *pi, double timeout_seconds, short events, unsigned int initialTicksCount, int errorOnTimeout);
int find_polling_descriptor(poll_info * pi, const char * poll_search_path, const char * poll_file_name);
int wait_for_poll_event(poll_info * pi);
#endif
