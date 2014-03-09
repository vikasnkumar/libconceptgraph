/* Copyright: Selective Intellect LLC
 * Author: Vikas N Kumar
 * Date: 24th March 2010
 */

#ifndef __ECGIF_TABLES_H__
#define __ECGIF_TABLES_H__

#include <string.h>

/* Make a copy of the input and store it in the strings table. Return back a
 * reference to the new copy and the length of the string in bytes.
 * Memory management is done internally.
 */
const char *table_strings_store(const char *input, size_t *length);

/* Returns a pointer to the reserved keyword/string that corresponds to the
 * given token. Memory management done internally.
 */
const char *table_reserved_get_by_token(unsigned long token);

/* Make a copy of the string and store in a symbol table. Symbol table can have
 * only unique strings unlike the strings table above which is just a stack of
 * all strings. Memory managed internally.
 * Returns pointer to symbol and updated length of symbol.
 */
const char *table_symbol_store(const char *input, size_t *length);

/* Generate a unique string in the symbol table, and return its length and a
 * pointer to the string. Memory managed internally.
 */
const char *table_symbol_generate(size_t *length);

#endif /* __ECGIF_TABLES_H__ */
