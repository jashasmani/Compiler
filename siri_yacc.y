%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex();
extern int yyerror(const char *msg);

typedef union {
    int num;
    char* str;
} SymValue;

SymValue sym[26];

%}

%union {
    int num;
    char* str;
}

%token <num> NUM
%token <str> IDENTIFIER STRING_LITERAL SIRI_INTGER SIRI_STRING
%token EQ SEMICOLON COMMA PRINT OPEN_PAREN CLOSE_PAREN OPEN_BRACE CLOSE_BRACE PLUS MINUS TIMES DIVIDE HEYSIRI 
%%

program: block
       ;

block: HEYSIRI OPEN_BRACE statement_list CLOSE_BRACE
       ;

statement_list: statement
              | statement_list statement
              ;

statement: declaration
         | print_statement
         ;

declaration: SIRI_INTGER IDENTIFIER EQ NUM SEMICOLON { sym[((char*)$2)[0] - 'a'].num = $4; }
           | SIRI_STRING IDENTIFIER EQ STRING_LITERAL SEMICOLON { sym[((char*)$2)[0] - 'a'].str = strdup($4); }
           | SIRI_INTGER IDENTIFIER EQ IDENTIFIER PLUS IDENTIFIER SEMICOLON { sym[((char*)$2)[0] - 'a'].num = sym[((char*)$4)[0] - 'a'].num + sym[((char*)$6)[0] - 'a'].num; }
           | SIRI_INTGER IDENTIFIER EQ IDENTIFIER MINUS IDENTIFIER SEMICOLON { sym[((char*)$2)[0] - 'a'].num = sym[((char*)$4)[0] - 'a'].num - sym[((char*)$6)[0] - 'a'].num; }
           | SIRI_INTGER IDENTIFIER EQ IDENTIFIER TIMES IDENTIFIER SEMICOLON { sym[((char*)$2)[0] - 'a'].num = sym[((char*)$4)[0] - 'a'].num * sym[((char*)$6)[0] - 'a'].num; }
           | SIRI_INTGER IDENTIFIER EQ IDENTIFIER DIVIDE IDENTIFIER SEMICOLON { 
                 if ($6 != 0) sym[((char*)$2)[0] - 'a'].num = sym[((char*)$4)[0] - 'a'].num / sym[((char*)$6)[0] - 'a'].num; 
                 else { 
                     yyerror("Division by zero\n"); 
                     exit(1); 
                 } 
             }
           ;

print_statement: PRINT OPEN_PAREN SIRI_INTGER COMMA IDENTIFIER CLOSE_PAREN SEMICOLON {
                 if (sym[((char*)$5)[0] - 'a'].num)
                     printf("the value of %s is %d\n",$5,sym[((char*)$5)[0] - 'a'].num);
                 else
                     printf("NULL\n");
               }
               | PRINT OPEN_PAREN SIRI_STRING COMMA IDENTIFIER CLOSE_PAREN SEMICOLON {
                 if (sym[((char*)$5)[0] - 'a'].str)
                     printf("the value of %s is %s\n",$5,sym[((char*)$5)[0] - 'a'].str);
                 else
                     printf("NULL\n");
               }
               | PRINT OPEN_PAREN SIRI_INTGER COMMA IDENTIFIER PLUS IDENTIFIER CLOSE_PAREN SEMICOLON {
                 printf("sum is %d\n", sym[((char*)$5)[0] - 'a'].num + sym[((char*)$7)[0] - 'a'].num);
               }
               | PRINT OPEN_PAREN SIRI_INTGER COMMA IDENTIFIER MINUS IDENTIFIER CLOSE_PAREN SEMICOLON {
                 printf("subtraction is %d\n", sym[((char*)$5)[0] - 'a'].num - sym[((char*)$7)[0] - 'a'].num);
               }
               | PRINT OPEN_PAREN SIRI_INTGER COMMA IDENTIFIER TIMES IDENTIFIER CLOSE_PAREN SEMICOLON {
                 printf("multiplication is %d\n", sym[((char*)$5)[0] - 'a'].num * sym[((char*)$7)[0] - 'a'].num);
               }
               | PRINT OPEN_PAREN SIRI_INTGER COMMA IDENTIFIER DIVIDE IDENTIFIER CLOSE_PAREN SEMICOLON {
                 if (sym[((char*)$7)[0] - 'a'].num != 0)
                     printf("devision is  %d\n", sym[((char*)$5)[0] - 'a'].num / sym[((char*)$7)[0] - 'a'].num);
                 else
                     printf("Division by zero\n");
               }
               ;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        return 1;
    }

    yyparse();

    fclose(yyin);

    return 0;
}
