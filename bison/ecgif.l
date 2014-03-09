/* Copyright: Selective Intellect LLC
 * Author: Vikas Kumar
 * Date: Nov 2009
 */

/* Definitions */
%top{
#include <stdlib.h>
#include <stdint.h>
#include "ecgif.tab.h"
#define ECGIF_TOKEN(x) ecgif_token(x, #x)
int ecgif_token(int, char *);
}
/*
 * D: Digit
 * L: Letter
 * E: Exponent
 * H: Hexadecimal
 * S: Special
 * C: Character
 * DQ: Double Quote
 * SQ: Single Quote
 * Q: Quotes
 * B: Backslash
 */
D  [0-9]
L  [a-zA-Z]
E  [Ee][+-]?[0-9]+
H  [a-fA-F0-9]+
S  [~!#$%\^&*()_\-=+{}\[\]|`:;,<>\./?]
C  ({D}|{L}|{S})
DQ \"
SQ '
B  \\


%x COMMENTS
%x END_COMMENTS
%pointer
/* do not use REJECT, yymore(), unput()*/
%option noreject noyymore nounput noinput
%option 8bit bison-bridge
%option warn 
%option yylineno
/* Maximal Posix compatibility */
%option posix-compat
/* Change the prefix to cgif_yy */
%option prefix="ecgif_yy"
/* Generate header file for usage by other yacc/bison files */
%option header-file="ecgif.lex.h"
%%
                  /* Rules */
"/*"                 { BEGIN COMMENTS; }
";"                  { BEGIN END_COMMENTS; }
<COMMENTS>"*/"       { BEGIN INITIAL; }
<COMMENTS>[.\n]*     { return ECGIF_TOKEN(COMMENT); }
<END_COMMENTS>"]"    { BEGIN INITIAL; return ECGIF_TOKEN(C_CLOSE); }
<END_COMMENTS>")"    { BEGIN INITIAL; return ECGIF_TOKEN(R_CLOSE); }
<END_COMMENTS>[.\n]* { return ECGIF_TOKEN(END_COMMENT); }
^[ \t\v\f\r\n]+$     ;/* ignore blank lines */

Either        { return ECGIF_TOKEN(EITHER); }
Or            { return ECGIF_TOKEN(OR); }
If            { return ECGIF_TOKEN(IF); }
Then          { return ECGIF_TOKEN(THEN); }
Iff           { return ECGIF_TOKEN(IFF); }
Equivalence   { return ECGIF_TOKEN(EQUIV); }
Equiv         { return ECGIF_TOKEN(EQUIV); }
Proposition   { return ECGIF_TOKEN(PROPOSITION); }
@every        { return ECGIF_TOKEN(EVERY); }
"..."         { return ECGIF_TOKEN(SEQ_MARK); }
"["           { return ECGIF_TOKEN(C_OPEN); }
"]"           { return ECGIF_TOKEN(C_CLOSE); }
"("           { return ECGIF_TOKEN(R_OPEN); }
")"           { return ECGIF_TOKEN(R_CLOSE); }
"*"           { return ECGIF_TOKEN(ASTERISK); }
":"           { return ECGIF_TOKEN(COLON); }
"~"           { return ECGIF_TOKEN(NEGATION); }
"#"           { return ECGIF_TOKEN(HASH_MARK); }
"?"           { return ECGIF_TOKEN(Q_MARK); }
"|"           { return ECGIF_TOKEN(PIPE); }
"@"           { return ECGIF_TOKEN(ATSIGN); }

{DQ}[^"]*{DQ} { return ECGIF_TOKEN(QUOTED_STRING); }
{SQ}[^']*{SQ}    { return ECGIF_TOKEN(QUOTED_STRING); }
{L}({L}|{D}|_)*  { return ECGIF_TOKEN(IDENTIFIER); }

{D}+{E}          { return ECGIF_TOKEN(DECIMAL); }
{D}*\.{D}+({E})? { return ECGIF_TOKEN(DECIMAL); }
{D}+\.{D}*({E})? { return ECGIF_TOKEN(DECIMAL); }
{D}+        { return ECGIF_TOKEN(NUMERAL); }
0x{H}|\x{H}   { return ECGIF_TOKEN(HEXADECIMAL); }
[ \t]+      ;/* ignore */
.           ;/* ignore anything else */

%%
/* User Code */

int ecgif_token(int type, char *typestr)
{
	printf("%s is %s\n", yytext, typestr);
	switch (type) {
	case NUMERAL:
		ecgif_yylval.integer = atol(yytext);
		break;
	case DECIMAL:
		ecgif_yylval.real = strtod(yytext, NULL);
		break;
	case HEXADECIMAL:
	case IDENTIFIER:
	case QUOTED_STRING:
	case COMMENT:
	case END_COMMENT:
		ecgif_yylval.string = yytext;
		break;
	default:
		ecgif_yylval.reserved = type;
		break;
	}
	return type;
}

int ecgif_yywrap()
{
	return 1;
}
