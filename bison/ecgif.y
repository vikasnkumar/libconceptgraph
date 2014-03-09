/* Copyright: Selective Intellect LLC
 * Author: Vikas N Kumar
 * Date: Nov 2009
 */

%{
#define YYLEX_PARAM (void *)0
/* Prologue */
#include <stdint.h>
#include "ecgif.lex.h"
#include "ecgif_ast.h"
int ecgif_yyerror(const char *);
static void print_token_value(FILE *, int, YYSTYPE);
#define YYPRINT(f, t, v) print_token_value(f, t, v)
%}

/* Declarations */
%require "2.3" /* minimum version requirement */
%name-prefix="ecgif_yy"
%defines
%debug
%locations
%token-table

%union {
	char *string;
	long integer;
	double real;
	unsigned long reserved;
	struct ecgif_ast_node *node;
	struct ecgif_ast *ast;
}

%token <reserved> C_OPEN C_CLOSE R_OPEN R_CLOSE
%token <reserved> PROPOSITION EVERY
%token <reserved> EQUIV IFF IF THEN EITHER OR
%token <reserved> NEGATION SEQ_MARK
%token <reserved> Q_MARK COLON ASTERISK PIPE ATSIGN
%token <reserved> HASH_MARK
%token <integer> NUMERAL
%token <real> DECIMAL
%token <string> HEXADECIMAL
%token <string> IDENTIFIER QUOTED_STRING
%token <string> COMMENT END_COMMENT
/* to force comment to get shifted */
%left C_OPEN
%left COMMENT
%start cgraph

%type <ast> cgraph cgraph_unit
%type <ast> proposition concept relation boolean
%type <ast> negation either_or if_then equivalence
%type <ast> nested_ors nested_or actor arc_sequence
%type <ast> arcs arc type_field referent_field
%type <ast> references type_expr
%type <node> cgname number seq_name reference
%type <node> cg_def_label cg_label

%%
/* Grammar Rules or Productions */
/* NOTE: To remove the ambiguities in the grammar, and to stick to LALR parsing
 * strategy of bison, empty cgraph is not used and instead the rules are
 * modified to account for a blank cgraph appropriately.
 */
cgraph: cgraph_unit { $$ = $<ast>1; }
		| cgraph cgraph_unit { $$ = ast_cons($<ast>1, $<ast>2); }
		;
cgraph_unit: concept { $$ = ast_set_type(AST_CG_CONCEPT, $<ast>1); }
		| relation { $$ = ast_set_type(AST_CG_RELATION, $<ast>1); }
		| boolean { $$ = ast_set_type(AST_CG_BOOLEAN, $<ast>1); }
		| COMMENT { $$ = ast_create(AST_CG_GENERIC,
							ast_node_create(ASTNODE_COMMENT, (void *)$<string>1)); }
		| proposition { $$ = ast_set_type(AST_CG_PROPOSITION, $<ast>1); }
		;
/* propositions are used to prevent assertions of each CG. a proposition is just
 * used to designate a CGname to a CG, as a naming/alias functionality. Will be
 * useful in creating ontologies. They do not assert a value, and can exist
 * anywhere since technically they create context, and are a subset of
 * "concept".
 */
proposition: c_open PROPOSITION colon cgname cgraph c_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, $<node>4),
						$<ast>5);
			}
		| c_open PROPOSITION colon cgraph c_close {
			$$ = ast_cons(ast_create(AST_CG_EMPTY, NULL), $<ast>4);
			} 
		| c_open PROPOSITION colon c_close {
				$$ = ast_create(AST_CG_EMPTY, NULL);
			} 
		;
boolean: negation { $$ = ast_set_type(AST_CG_NEGATION, $<ast>1); }
		| either_or { $$ = ast_set_type(AST_CG_EITHER_OR, $<ast>1); }
		| if_then { $$ = ast_set_type(AST_CG_IF_THEN, $<ast>1); }
		| equivalence { $$ = ast_set_type(AST_CG_EQUIV, $<ast>1); }
		;
negation: NEGATION c_open cgraph c_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>1)),
							$<ast>3);
			}
		| NEGATION c_open c_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>1)),
						ast_create(AST_CG_EMPTY, NULL));
			}
		;
either_or: c_open EITHER colon nested_ors c_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
						$<ast>4);
			}
		;
nested_ors: /* empty */ { $$ = ast_create(AST_CG_EMPTY, NULL); }
		| nested_ors nested_or { $$ = ast_cons($<ast>1, $<ast>2); }
		;
nested_or: c_open OR colon cgraph c_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
							$<ast>4);
			}
		| c_open OR colon c_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
							$<ast>4);
			}
		;
if_then: c_open IF colon cgraph
		c_open THEN colon cgraph c_close
		c_close {
			$$ = ast_cons(
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
					$<ast>4),
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>6)),
					$<ast>8)
				);
			}
		| c_open IF colon cgraph
		c_open THEN colon c_close
		c_close {
			$$ = ast_cons(
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
					$<ast>4),
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>6)),
					ast_create(AST_CG_EMPTY, NULL))
				);
			}
		| c_open IF colon
		c_open THEN colon cgraph c_close
		c_close {
			$$ = ast_cons(
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
					ast_create(AST_CG_EMPTY, NULL)),
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>5)),
					$<ast>7)
				);
			}
		| c_open IF colon
		c_open THEN colon c_close
		c_close {
			$$ = ast_cons(
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)),
					ast_create(AST_CG_EMPTY, NULL)),
				ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>5)),
					ast_create(AST_CG_EMPTY, NULL))
				);
			}
		;
equivalence: c_open EQUIV colon
		c_open IFF colon cgraph c_close
		c_open IFF colon cgraph c_close
		c_close {
			$$ = ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)
					),
					ast_cons(
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>5)),
							$<ast>7),
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>10)),
							$<ast>12)
					)
				);
			}
		| c_open EQUIV colon
		c_open IFF colon cgraph c_close
		c_open IFF colon c_close
		c_close {
			$$ = ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)
					),
					ast_cons(
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>5)),
							$<ast>7),
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>10)),
							ast_create(AST_CG_EMPTY, NULL))
					)
				);
			}
		| c_open EQUIV colon
		c_open IFF colon c_close
		c_open IFF colon cgraph c_close
		c_close {
			$$ = ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)
					),
					ast_cons(
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>5)),
							ast_create(AST_CG_EMPTY, NULL)),
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>9)),
							$<ast>11)
					)
				);
			}
		| c_open EQUIV colon
		c_open IFF colon c_close
		c_open IFF colon c_close
		c_close {
			$$ = ast_cons(
					ast_create(AST_CG_GENERIC, ast_node_create(
							ASTNODE_RESERVED, (void *)&$<reserved>2)
					),
					ast_cons(
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>5)),
							ast_create(AST_CG_EMPTY, NULL)),
						ast_cons(
							ast_create(AST_CG_GENERIC, ast_node_create(
								ASTNODE_RESERVED, (void *)&$<reserved>9)),
							ast_create(AST_CG_EMPTY, NULL))
					)
				);
			}
		;
/* Relation rule */
/* relation: ordinary-relation | actor */
relation: r_open HASH_MARK Q_MARK cgname arc_sequence r_close {
			/* FIXME: this might not be an ideal implementation */
			$$ = ast_cons(ast_create(AST_CG_GENERIC, 
						ast_node_create(ASTNODE_BOUND_FUNCTION, (void *)$<node>4)),
					$<ast>5
				);
			}
		| r_open cgname arc_sequence r_close {
			$$ = ast_cons(ast_create(AST_CG_GENERIC, $<node>2), $<ast>3);
			}
		| actor { $$ = $<ast>1; }
		;
actor: r_open HASH_MARK Q_MARK cgname arc_sequence PIPE arcs r_close {
			$$ = ast_create(AST_CG_ACTOR,
						ast_node_create(ASTNODE_CGRAPH,
							(void *)ast_cons( 
								ast_cons(
									ast_create(AST_CG_GENERIC,
									ast_node_create(ASTNODE_BOUND_FUNCTION,
									(void *)$<node>4)),
								$<ast>5),
							$<ast>7)
						)
				);
			}
		| r_open cgname arc_sequence PIPE arcs r_close {
			$$ = ast_create(AST_CG_ACTOR,
						ast_node_create(ASTNODE_CGRAPH,
							(void *)ast_cons(
								ast_cons(
									ast_create(AST_CG_GENERIC,
										$<node>2),
									$<ast>3),
								$<ast>5)
						)
				);
			}
		;
/* dereferencing the seq_name here */
arc_sequence: arcs COMMENT Q_MARK seq_name {
			$$ = ast_cons($<ast>1,
				ast_create(AST_CG_SEQUENCE, (void *)$<node>4));
			}
		| arcs Q_MARK seq_name {
			$$ = ast_cons($<ast>1,
				ast_create(AST_CG_SEQUENCE, (void *)$<node>3));
			}
		| arcs { $$ = $<ast>1; }
		;
arcs: /* empty */ { $$ = ast_create(AST_CG_EMPTY, NULL); }
		| arcs COMMENT arc { $$ = ast_cons($<ast>1, $<ast>3); }
		| arcs arc { $$ = ast_cons($<ast>1, $<ast>2); }
		;
arc: reference { $$ = $<ast>1; }
		| cg_def_label {
			$$ = ast_create(AST_CG_GENERIC, (void *)$<node>1);
			}
		| concept { $$ = $<ast>1; }
		;
/* Concept rule */
concept: c_open type_field referent_field c_close {
			$$ = ast_cons($<ast>2, $<ast>3);
			}
		| c_open referent_field c_close {
			$$ = ast_cons(ast_create(AST_CG_EMPTY, NULL), $<ast>2);
			}
		| c_open EVERY ASTERISK seq_name c_close {
			$$ = ast_create(AST_CG_GENERIC,
						ast_node_create(ASTNODE_UNIVERAL_QUANTIFIER, 
							ast_node_create(ASTNODE_DEFINER,
								(void *)$<node>4)));
			}
		| c_open ASTERISK seq_name c_close {
			$$ = ast_create(AST_CG_GENERIC,
							ast_node_create(ASTNODE_DEFINER,
								(void *)$<node>3));
			}
		;
type_field: type_expr COLON { $$ = $<ast>1; }
		| HASH_MARK Q_MARK cgname colon {
			$$ = ast_create(AST_CG_GENERIC,
					ast_node_create(ASTNODE_BOUND_FUNCTION, (void *)$<node>3));
			}
		| cgname COLON /* minor change from ISO doc to remove conflicts
with reference non-terminal */ {
			$$ = ast_create(AST_CG_GENERIC, $<node>1);
			}
		| COLON { $$ = ast_create(AST_CG_EMPTY, NULL); }
		;
referent_field: cg_label references cgraph {
			$$ = ast_cons(
					ast_create(AST_CG_GENERIC, $<node>1),
					ast_cons($<ast>2, $<ast>3));
			}
		| cg_label cgraph /* zero references */ {
			$$ = ast_cons(
					ast_create(AST_CG_GENERIC, $<node>1),
					$<ast>2);
			}
		| references cgraph /* optional cg_label */ {
			$$ = ast_cons($<ast>1, $<ast>2);
			}
		| cg_label references /* blank cgraph */ {
			$$ = ast_cons( 
					ast_create(AST_CG_GENERIC, $<node>1),
					$<ast>2);
			}
		| references /* blank cgraph */ { $$ = $<ast>1; }
		| cgraph /* optional cg_label and 0 references */ {
			$$ = $<ast>1;
			}
		| cg_label /* 0 references and blank cgraph */ {
			$$ = ast_create(AST_CG_GENERIC, $<node>1);
			}
		| /* empty: everything optional */ {
			$$ = ast_create(AST_CG_EMPTY, NULL);
			}
		;
type_expr: ATSIGN ASTERISK cgname cgraph {
			$$ = ast_cons(ast_create(AST_CG_TYPE_EXPR,
							(void *)$<node>3), $<ast>4);
			}
		;
cg_label: EVERY cg_def_label {
			$$ = ast_node_create(ASTNODE_UNIVERAL_QUANTIFIER, (void *)$<node>2);
			}
		| cg_def_label { $$ = $<node>1; }
		;
cg_def_label: ASTERISK cgname {
			$$ = ast_node_create(ASTNODE_DEFINER, 
					(void *)$<node>2);
			}
		;
/* references is 1 or more. the 0 condition handled elsewhere */
references: reference {
			$$ = ast_create(AST_CG_GENERIC, $<node>1);
			}
		| references reference {
			$$ = ast_cons($<ast>1, ast_create(AST_CG_GENERIC, $<node>1));
			}
		;
reference: Q_MARK cgname {
			$$ = ast_node_create(ASTNODE_BOUND_COREFERENCE, (void *)$<node>1);
			}
		| cgname { $$ = $<node>1; }
		;
seq_name: SEQ_MARK cgname {
			$$ = ast_node_create(ASTNODE_SEQUENCE, (void *)$<node>2);		
			}
		| SEQ_MARK {
			$$ = ast_node_create(ASTNODE_SEQUENCE, NULL);
			}
		;
cgname: IDENTIFIER {
			$$ = ast_node_create(ASTNODE_IDENTIFIER, (void*)$<string>1);
			printf("%s", ecgif_yylval.string);
			}
		| QUOTED_STRING {
			$$ = ast_node_create(ASTNODE_QUOTED_STRING, (void *)$<string>1);
			}
		| number { $$ = $<node>1; }
		;
number: NUMERAL { $$ = ast_node_create(ASTNODE_INTEGER, (void *)&$<integer>1); }
		| DECIMAL { $$ = ast_node_create(ASTNODE_REAL, (void *)&$<real>1); }
		| HEXADECIMAL {
			/* TODO: figure how to handle hexadecimals */
			$$ = ast_node_create(ASTNODE_QUOTED_STRING, (void *)$<string>1);
			}
		;
c_open: C_OPEN COMMENT
		| C_OPEN
		;
c_close: END_COMMENT C_CLOSE
		| C_CLOSE
		;
r_open: R_OPEN COMMENT
		| R_OPEN
		;
r_close: END_COMMENT R_CLOSE
		| R_CLOSE
		;
colon: /* empty */
		| COLON
		;
%%

/* Epilogue */
int main(int argc, char **argv)
{
	yydebug = argc - 1;
	return ecgif_yyparse();
}	

int ecgif_yyerror(const char *err)
{
	fprintf(stderr, "ERROR IN ECGIF BISON. %s\n", err);
	return 0;
}

void print_token_value(FILE *f, int t, YYSTYPE v)
{
	switch (t) {
	case NUMERAL:
		fprintf(f, "Token No:%d Integer: %ld\n", t, v.integer);
		break;
	case DECIMAL:
		fprintf(f, "Token No:%d Decimal: %e\n", t, v.real);
		break;
	case HEXADECIMAL:
	case IDENTIFIER:
	case QUOTED_STRING:
	case COMMENT:
	case END_COMMENT:
		fprintf(f, "Token No:%d String: %s\n", t, v.string);
		break;
	default:
		fprintf(f, "Token No:%d Reserved: %s\n", t, 
					yytname[YYTRANSLATE(t)]);
		break;
	}
}
