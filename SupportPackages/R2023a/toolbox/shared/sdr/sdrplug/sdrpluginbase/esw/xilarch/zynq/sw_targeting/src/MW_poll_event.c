/* Copyright 2013-2016 The MathWorks, Inc. */

/* ------------------------------------------------------------------ */
/* This source file will only get added if specified by the user      */
/* in the coder target options for interrupt based timing             */
/* ------------------------------------------------------------------ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <time.h>
#include <dirent.h>
#include <sys/stat.h>

#include <MW_poll_event.h>

#define MAX_BUF 64

#define MAX_NAME 256
#define MAX_PAT_NAME 16
#define MAX_DESC_FILE_NAME 1024

/**************************************************************************
 * @brief setTimespecForPolling.
 * Pass in a timespec pointer pointer ts, and a double value of seconds
 * Negative values will result in setting the pointer to NULL
 * Positive values will allocate a struct and set the appropriate timespec.
 *************************************************************************/
static int setTimespecForPolling(struct timespec **ts, double seconds)
{
    struct timespec *lts; /*local timespec to set up */
    if(seconds < 0)
    {
        /* block indefinitely */
        lts = NULL;
    }
    else
    {
        lts = malloc(sizeof(*lts));
        lts->tv_sec = (time_t) seconds;
        lts->tv_nsec = (seconds - lts->tv_sec) * 1000000000;
    }
    *ts = lts; /* Assign local timespec to caller */
    return 0;
}
/**************************************************************************
 * @brief file_tree_walk_recursive
 * This module searches for a file file_name under a start_dir and
 * returns a file_found flag and full file_path to caller
 **************************************************************************/
static int file_tree_walk_recursive(const char * start_dir, const char * file_name, size_t max_length, int *file_found, char * file_path) {
    DIR *d;
    struct dirent *dir;
    int ret = 0;
    int dlen = strlen(start_dir);
    int nextLen = dlen + MAX_NAME + 2;
    char *tfname;
    char * matched;
    struct stat tfstat;
    char search_pat[MAX_PAT_NAME];

    tfname = (char *)malloc(nextLen);
    if (NULL == tfname){
        fprintf(stderr,"Unable to allocate %d bytes for filename\n",nextLen);
        exit(EXIT_FAILURE);
    }
    if (dlen >= FILENAME_MAX-1) {
        fprintf(stderr, "Name exceeds file-name limits\n");
        ret = -1;
        free(tfname);
        exit(EXIT_FAILURE);
    }
    if (!(d = opendir(start_dir))){
        fprintf(stderr,"Unable to open file %s\n",start_dir);
        free(tfname);
        exit(EXIT_FAILURE);
    }
    while((dir = readdir(d)) && ( 0 == *file_found)){
        /* Exit if the name of file is more than MAX_NAME characters */
        if (strlen(dir->d_name) > MAX_NAME){
            fprintf(stderr,"This file/directory name exceeds %d characters.\n", MAX_NAME);
            free(tfname);
            exit(EXIT_FAILURE);
        }        
        snprintf(search_pat, MAX_PAT_NAME, "%s", file_name);
        if (!strcmp(dir->d_name, ".") || !strcmp(dir->d_name, "..")){
            continue;
        }
        snprintf(tfname, nextLen, "%s/%s",start_dir,dir->d_name);
        if (lstat(tfname,&tfstat) == -1) {
            fprintf(stderr,"Cannot stat file - %s\n",tfname);
            ret = -1;
            continue;
        }
        if (S_ISLNK(tfstat.st_mode)){
            continue; // DMA descriptor is not a SYMLINK
        }
        if (S_ISDIR(tfstat.st_mode)) {
            file_tree_walk_recursive(tfname, file_name, max_length, file_found, file_path);
        }
        matched = strstr(tfname, search_pat);
        if (matched && *matched && (strlen(matched) == strlen(search_pat)) ) {
            snprintf(file_path, max_length,"%s",tfname);
            *file_found = 1;
            ret = 0;
        }
    }
    if (NULL != tfname){
        free(tfname);
    }
    if (d) {
        closedir(d);
    }
    return ret;
}
int find_polling_descriptor(poll_info * pi, const char * poll_search_path, const char * poll_file_name)
{

    size_t max_length = MAX_DESC_FILE_NAME;
    pi->fdPath = malloc(sizeof(*pi->fdPath) * max_length);
    file_tree_walk_recursive(poll_search_path, poll_file_name, max_length, &(pi->fd), pi->fdPath);
    if(!pi->fd)
    {
        fprintf(stderr,"File '%s' for polling not found under directory '%s'\n", POLL_FILE_NAME, POLL_SEARCH_PATH);
        exit(EXIT_FAILURE);
    }
    return 0;
}
/* ----------------------------------------------------------------    
 * Setup file descriptor poll_info->pd for polling.
 * Add events to listen to on poll descriptor
 * The number of events to skip for initialisation purposes
 * If we want to assert an error condition when a timeout occurs
 ----------------------------------------------------------------    */
int setup_polling_descriptor(poll_info *pi, double timeout_seconds, short events, unsigned int initialTicksCount, int errorOnTimeout)
{
    int fd;
    char fdBuf[2];
    int ret = 0;
    /* check if fd is valid before setting up */
    if(!pi->fd)
    {
        fprintf(stderr,"Invalid poll_info struct\n");
        fflush(stderr);
        return -1;
    }
    /*  Now open file descriptor non-blocking / read-only */
    fd = open(pi->fdPath, O_RDONLY | O_NONBLOCK );
    if (fd < 0) {
        fprintf(stderr, "Could not open file descriptor \"%s\" \n", pi->fdPath);
        fflush(stderr);
    }
    /* Let's put a lock on this so any downstream code can check it */
    ret = flock(fd, LOCK_EX | LOCK_NB);
    if(ret < 0)
    {
        perror("Advisory lock on poll descriptor failed. Cannot use for event based scheduler.");
        return -1;
    }
    read(fd,fdBuf,1); /* Ensure first read occurs to avoid spurious poll event */

    pi->initialTicksCount = initialTicksCount;
    pi->fdset[0].fd = fd;
    pi->fdset[0].events = events;
    pi->fdset[0].revents = 0;
    setTimespecForPolling(&pi->timeout, timeout_seconds);

    pi->errorOnTimeout = errorOnTimeout;

    return fd;  

}

/* -------------------------------------------------------
 * Poll on file descriptor
 * -------------------------------------------------------*/
int wait_for_poll_event(poll_info * pi)
{
    int ret;
    char *buf[MAX_BUF];
    int len;
    if(pi->initialTicksCount)
    {
        pi->initialTicksCount--;
        return;
    }
    ret = ppoll(&(pi->fdset[0]), 1, pi->timeout, NULL);
    if (ret > 0) {
        short all_events = (pi->fdset[0].revents & pi->fdset[0].events);
        if (all_events) {
            lseek(pi->fdset[0].fd, 0, SEEK_SET);
            len = read(pi->fdset[0].fd, buf, sizeof(buf));
            return 0;
        } else {
            fprintf(stderr, "revents:0x%hx, events:0x%hx\n", pi->fdset[0].revents, pi->fdset[0].events);
            return -1;
        }
    } else if (ret == 0) {
        if(pi->errorOnTimeout)
        {
            /* We should find a nice way to expose this condition directly in the model */
            fprintf(stderr, "Timeout occured when polling for event. Error condition. Killing model\n");
            sleep(5);
            exit(EXIT_FAILURE);
        }
        else
        {
            return -ETIMEDOUT;
        }
    } else{
        fprintf(stderr, "Poll failed.\n");
        fprintf(stderr, "revents:0x%hx, events:0x%hx\n",pi->fdset[0].revents, pi->fdset[0].events);
        return -EINVAL;
    }

}

