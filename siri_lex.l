%{
#include "y.tab.h"
%}

digit           [0-9]
letter          [a-zA-Z]
identifier      {letter}({letter}|{digit})*
number          {digit}+
whitespace      [ \t\n]
comment         \/\/[^\n]*

%%

"="             		{ return EQ; }
";"             		{ return SEMICOLON; }
","             		{ return COMMA;}
"("             		{ return OPEN_PAREN;}
")"             		{ return CLOSE_PAREN;}
"siri_say"   { return PRINT; }
"+"             		{ return PLUS; }
"-"             		{ return MINUS; }
"*"             		{ return TIMES; }
"/"             		{ return DIVIDE; }
"siri_intger"      		{ return SIRI_INTGER; }
"siri_string"   		{ return SIRI_STRING; }
"HeySiri"     		    { return HEYSIRI; }
"{"             		{ return OPEN_BRACE; }
"}"             		{ return CLOSE_BRACE; }
{identifier}    		{ yylval.str = strdup(yytext); return IDENTIFIER; }
{number}        		{ yylval.num = atoi(yytext); return NUM; }

"\""[^\"]*"\"" 			{ yylval.str = strdup(yytext); return STRING_LITERAL; }
{comment}       		; /* Ignore single-line comments */
{whitespace}    		;
.               		{ fprintf(stderr, "Invalid character: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}

