/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "lexer.h"
#include "symbols_table.h"


int yyerror(const char *);


extern char *filename;
extern int column_counter;
extern SymbolsTable symbolsTable;

%}



/* *** *** section de déclaration *** *** */

%token TYPE_INTEGER TYPE_FLOAT TYPE_BOOLEAN TYPE_CHAR TYPE_STRING
%token VOID
%token INTEGER_LITERAL FLOAT_LITERAL BOOLEAN_LITERAL CHAR_LITERAL STRING_LITERAL

%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token AND OR NOT
%token EQUAL NOT_EQUAL LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL

%token LEFT_PARENTHESIS RIGHT_PARENTHESIS
%token LEFT_BRACE RIGHT_BRACE
%token LEFT_BRACKET RIGHT_BRACKET

%token COLON SEMICOLON DOT COMMA
%token RETURN ASSIGN LET IDENTIFIER

%token HTPL_BEGIN HTPL_END
%token FUNCTION_BEGIN FUNCTION_END FUNCTION_NAME MAIN READ WRITE
%token IF_BEGIN IF_END ELSE
%token WHILE_BEGIN WHILE_END
%token STRUCT_BEGIN STRUCT_END



/* *** *** section des actions *** *** */

%start program

%%

program: HTPL_BEGIN code HTPL_END;
code: main;
main: FUNCTION_BEGIN signature GREATER body FUNCTION_END;
signature: MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON VOID;
body: WRITE LEFT_PARENTHESIS STRING_LITERAL RIGHT_PARENTHESIS SEMICOLON;

%%



/* *** *** section de code *** *** */

int yyerror(const char *error_message) {
	printf("File \"%s\", line %d, character %d: Syntax Error, unexpected token '%s'\n", filename, yylineno, column_counter, yytext);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    filename = argv[1];
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error opening the file: %s\n", argv[1]);
        return 1;
    }

    yyset_in(file);

    initializeSymbolsTable(&symbolsTable);

    yyparse();

    fclose(file);

    printf("\n");
    printSymbolsTable(&symbolsTable);
    printf("\n");

    deleteSymbolsTable(&symbolsTable);

    return 0;
}
