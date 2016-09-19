/**
 * The contents of this file are subject to the terms of the Common Development and
 * Distribution License (the License). You may not use this file except in compliance with the
 * License.
 *
 * You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
 * specific language governing permission and limitations under the License.
 *
 * When distributing Covered Software, include this CDDL Header Notice in each file and include
 * the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
 * Header, with the fields enclosed by brackets [] replaced by your own identifying
 * information: "Portions copyright [year] [name of copyright owner]".
 *
 * Copyright 2014 - 2016 ForgeRock AS.
 */

#include <stdio.h>
#include <stdlib.h>
//#include <stdint.h>

#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

#include <sys/mman.h>
#include <sys/shm.h>
#include <semaphore.h>

#include "am.h"
#include "utility.h"
#include "share.h"
#include "error.h"


/*
 * map entire shared memory into virtual memory
 *
 * the callack (cb) is called when the block is first opened and it is for initialisaiton of the block
 *
 */
int get_memory_segment(am_shm_t **p_addr, char *name, size_t sz, void (*cb)(void *cbdata, void *p), void *cbdata, int id)
{
    if (p_addr == NULL) {
        return AM_FAIL;
    }

    *p_addr = am_shm_create(get_global_name(name, id), ((uint64_t) sz), AM_TRUE);
    if (*p_addr == NULL) {
        return AM_ERROR;
    }
    if ((*p_addr)->error != AM_SUCCESS) {
        return (*p_addr)->error;
    }

    if ((*p_addr)->init) {
        cb(cbdata, (*p_addr)->basePtr);
    }

    return AM_SUCCESS;
}

/*
 * unmap and optionlly unlink a shared memory segment
 *
 */
int remove_memory_segment(am_shm_t **p_addr)
{
    if (p_addr == NULL) {
        return AM_FAIL;
    }
    am_shm_shutdown(*p_addr);
    *p_addr = NULL;
    return AM_SUCCESS;
}
