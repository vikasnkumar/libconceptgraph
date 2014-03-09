/* Copyright: Selective Intellect LLC
 * Author: Vikas N Kumar
 * Date: 27th March 2010
 */

#ifndef __MEMORY_Q_H__
#define __MEMORY_Q_H__

#include <stdlib.h>
#include <stdint.h>

#define MEMQ_MANUALFREE 0
#define MEMQ_AUTOFREE 1

/* Allocates the required size of bytes and provides a pointer to the newly
 * allocated memory location. The flags variable tells the manager whether the
 * memory management will be done by the user or by the manager itself.
 * Default is to be done by the manager.
 */
void *memq_alloc(size_t bytes, uint8_t flags);

/* Free the memory that has been allocated by the memory queue manager
 */
void *memq_free(void *data);

#endif /* __MEMORY_Q_H__ */
