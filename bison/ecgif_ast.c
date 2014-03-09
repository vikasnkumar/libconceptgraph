/* Copyright: Selective Intellect LLC
 * Author: Vikas N Kumar
 * Date: 24th March 2010
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ecgif_ast.h"
#include "memoryq.h"
#include "tables.h"

struct ecgif_ast_node *ast_node_create(AstNodeType type, void *data)
{
	struct ecgif_ast_node *node = memq_alloc(sizeof(struct ecgif_ast_node), MEMQ_AUTOFREE);	

	if (!node) {
		return NULL;
	}
	/* the "data" parameter can be NULL for specific types which will be handled
	 * appropriately */
	node->type = ASTNODE_UNDEFINED;

	switch (type) {
	case ASTNODE_COMMENT:
		{
			size_t length = 0;
			const char *ptr = NULL;
			if (data) {
				ptr = table_strings_store((const char *)data, &length);
			}
			/* a NULL comment is removed */
			if (ptr && length > 0) {
				node->type = type;
				node->data.string.length = length;
				node->data.string.bytes = ptr;
			}
		}
		break;
	case ASTNODE_RESERVED:
		{
			if (data) {
				unsigned long *token = (unsigned long *)data;
				node->type = type;
				node->data.reserved.keyword = table_reserved_get_by_token(*token);
				node->data.reserved.token = *token;
			}
		}
		break;
	case ASTNODE_INTEGER:
		{
			if (data) {
				long *integer = (long *)data;
				node->type = type;
				node->data.integer = *integer;
			}
		}
		break;
	case ASTNODE_REAL:
		{
			if (data) {
				double *real = (void *)data;
				node->type = type;
				node->data.real = *real;
			}
		}
		break;
	case ASTNODE_QUOTED_STRING:
		{
			size_t length = 0;
			/* this should allow for NULL strings. Hence "data" does not matter*/
			const char *ptr = table_strings_store((const char *)data, &length);
			if (ptr) {
				node->type = type;
				node->data.string.length = length;
				node->data.string.bytes = ptr;
			}
		}
	case ASTNODE_IDENTIFIER:
		{
			size_t length = 0;
			const char *ptr = NULL;
			if (data) {
				ptr = table_symbol_store((const char *)data, &length);
			}
			/* this should not allow NULL strings */
			if (ptr && length > 0) {
				node->type = type;
				node->data.string.length = length;
				node->data.string.bytes = ptr;
			}
		}
		break;
	case ASTNODE_SEQUENCE:
		{
			size_t length = 0;
			const char *ptr = NULL;
			/* a NULL value of "data" creates an anonymous symbol */
			if (data) {
				ptr = table_symbol_store((const char *)data, &length);
			} else {
				ptr = table_symbol_generate(&length);
			}
			if (ptr && length > 0) {
				node->type = type;
				node->data.sequence.length = length;
				node->data.sequence.name = ptr;
				node->data.sequence.ref = NULL;
			}
		}
		break;	
	case ASTNODE_DEFINER:
		{
			if (data) {
				node->type = type;
				node->data.definer.ref = (struct ecgif_ast_node *)data;
			}
		}
		break;
	case ASTNODE_BOUND_COREFERENCE:
		{
			if (data) {
				node->type = type;
				node->data.boundref.ref = (struct ecgif_ast_node *)data;
				node->data.boundref.cgref = NULL;
			}	
		}
		break;
	case ASTNODE_BOUND_FUNCTION:
		{
			if (data) {
				node->type = type;
				node->data.boundref.ref = (struct ecgif_ast_node *)data;
				node->data.boundref.cgref = NULL;
			}
		}
		break;
	case ASTNODE_UNIVERAL_QUANTIFIER:
		{
			if (data) {
				node->type = type;
				node->data.definer.ref = (struct ecgif_ast_node *)data;
			}
		}
		break;
	case ASTNODE_CGRAPH:
		{
			/* an empty CG can exist but it should be tagged as AST_CG_EMPTY 
			 * hence data cannot be NULL
			 */
			if (data) {
				node->type = type;
				node->data.cg.ref = (struct ecgif_ast *)data;
			}
		}
		break;
	default:
		break;
	}
	if (node->type == ASTNODE_UNDEFINED) {
		node = memq_free(node);
	}
	return node;
}

struct ecgif_ast *ast_create(AstType type, struct ecgif_ast_node *node)
{
	switch (type) {
	case AST_CG_EMPTY:
	case AST_CG_GENERIC:
	case AST_CG_CONCEPT:
	case AST_CG_RELATION:
	case AST_CG_ACTOR:
	case AST_CG_TYPE_EXPR:
	case AST_CG_PROPOSITION:
	case AST_CG_BOOLEAN:
	case AST_CG_NEGATION:
	case AST_CG_EITHER_OR:
	case AST_CG_EQUIV:
	case AST_CG_IF_THEN:
	case AST_CG_SEQUENCE:		
	default:
		break;
	}
	return NULL;
}

struct ecgif_ast *ast_cons(struct ecgif_ast *first, struct ecgif_ast *last)
{
	return NULL;
}

struct ecgif_ast *ast_set_type(AstType type, struct ecgif_ast *ast)
{
	return NULL;
}
