/* Copyright: Selective Intellect LLC
 * Author: Vikas Kumar
 * Date: 8th March 2010
 */

#ifndef __ECGIF_AST_AST_H__
#define __ECGIF_AST_AST_H__

/* The concept of these structures is that each node in the tree is the tree
 * itself since a tree could exist with just one node technically and a list
 * could exist with 1 element and no next/prev elements as well. Each node can
 * be of basic element type of identifier(string) or a number(long/double) and
 * can also be a reference to another node which can be represented by a pointer
 * (void *)
 */

struct ecgif_ast_node;
struct ecgif_ast;

/* all the different types of basic entities that ECGIF handles need to be
 * represented in the node
 */
typedef enum {
	/* undefined node */
	ASTNODE_UNDEFINED,
	/* a comment */
	ASTNODE_COMMENT,
	/* all the reserved keywords that form an important part of the tree */
	ASTNODE_RESERVED, 
	/* any value that is an integer */
	ASTNODE_INTEGER,
	/* any value that is a real number */
	ASTNODE_REAL,
	/* all quoted strings */
	ASTNODE_QUOTED_STRING,
	/* all identifiers are by default constants */
	ASTNODE_IDENTIFIER,
	/* a sequence marker. can be named or anonymous */
	ASTNODE_SEQUENCE,
	/* a defining label denoted by *cgname or *...seqmark */
	ASTNODE_DEFINER,
	/* a reference to the variable defined earlier ?cgname */
	ASTNODE_BOUND_COREFERENCE,
	/* an identifier that is dereferenced to be a function #?cgname */
	/* valid only for relations */
	ASTNODE_BOUND_FUNCTION,
	/* meta tags for the concept in question */
	ASTNODE_UNIVERAL_QUANTIFIER,
	/* a lambda concept reference denoted by @*cgname  */
	/* cgraph and other similar units */
	ASTNODE_CGRAPH
} AstNodeType;

struct ecgif_ast_node {
	AstNodeType type;
	union __data {
		struct __reserved {
			/* this is const since it is compile-time defined */
			const char *keyword;
			unsigned long token;
		} reserved;

		/* using this to see if quantification can be handled separately or
		 * should be part of the node. it is a meta tag but need not always be
		 * part of a node.*/
		unsigned long quantifier;

		long integer;
		
		double real;
		
		struct __string {
			size_t length;
			const char *bytes;
		} string;
		
		struct __sequence {
			size_t length;
			const char *name;
			struct ecgif_ast *ref;
		} sequence;
		
		struct __definer {
			struct ecgif_ast_node *ref;
		} definer;
		
		struct __boundref {
			struct ecgif_ast_node *ref;
			struct ecgif_ast *cgref;
		} boundref;

		struct __cg {
			struct ecgif_ast *ref; 
		} cg;
	} data;
};

typedef enum {
	AST_CG_EMPTY,
	AST_CG_GENERIC,
	AST_CG_CONCEPT,
	AST_CG_RELATION,
	AST_CG_ACTOR,
	AST_CG_TYPE_EXPR,
	AST_CG_PROPOSITION,
	AST_CG_BOOLEAN,
	AST_CG_NEGATION,
	AST_CG_EITHER_OR,
	AST_CG_EQUIV,
	AST_CG_IF_THEN,
	AST_CG_SEQUENCE
} AstType;

struct ecgif_ast {
	AstType type;
	struct ecgif_ast_node *node;
	struct ecgif_ast *next;
};

/* create an ast_node from the given data */
struct ecgif_ast_node *ast_node_create(AstNodeType type, void *data);

/* create a new ast from a single node */
struct ecgif_ast *ast_create(AstType type, struct ecgif_ast_node *node);

/* joins 2 ast's into a new ast and returns the new ast */
struct ecgif_ast *ast_cons(struct ecgif_ast *first, struct ecgif_ast *last);

/* sets the type of the current ast root node and returns the modified ast*/
struct ecgif_ast *ast_set_type(AstType type, struct ecgif_ast *ast);


#endif /* __ECGIF_AST_AST_H__ */
