/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "symbols_table.h"

extern int yylineno;
extern char *yytext;

int yylex();
int yyerror(const char *);
int checkTypeCompatibility(char *, char *);

extern char *filename;
extern int column_counter;
extern SymbolsTable symbolsTable;

%}

/* *** *** section de déclaration *** *** */

%token LET RETURN WRITE READ
%token FUNCTION_BEGIN FUNCTION_END MAIN FUNCTION_NAME
%token IF_BEGIN IF_END ELSE WHILE_BEGIN WHILE_END
%token TYPE_INTEGER TYPE_FLOAT TYPE_STRING TYPE_BOOLEAN TYPE_CHAR 
%token VOID
%token INTEGER_LITERAL FLOAT_LITERAL STRING_LITERAL BOOLEAN_LITERAL CHAR_LITERAL
%token LEFT_BRACKET RIGHT_BRACKET STRUCT_BEGIN STRUCT_END
%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token ASSIGN
%token EQUAL NOT_EQUAL LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL
%token COLON AND OR NOT
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS
%token LEFT_BRACE RIGHT_BRACE SEMICOLON COMMA DOT
%token HTPL_BEGIN HTPL_END
%token IDENTIFIER

%nonassoc EQUAL NOT_EQUAL LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL
%nonassoc ASSIGN

%left OR
%left AND
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%left NOT
%left LEFT_PARENTHESIS RIGHT_PARENTHESIS

/* *** *** section des actions *** *** */

%start program

%% 

program: HTPL_BEGIN code HTPL_END;

code: main
    | declarations main
    ;

declarations: declaration declarations
    | %empty
    ;

declaration: LET IDENTIFIER COLON type ASSIGN expression SEMICOLON
    | LET IDENTIFIER COLON type SEMICOLON
    | function_declaration
    | struct_declaration
    ;

type: TYPE_INTEGER
    | TYPE_FLOAT
    | TYPE_STRING
    | TYPE_BOOLEAN
    | TYPE_CHAR
    | array_type
    ;

array_type: TYPE_INTEGER LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
    | TYPE_FLOAT LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
    | TYPE_STRING LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
    | TYPE_BOOLEAN LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
    | TYPE_CHAR LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
    ;

struct_declaration: STRUCT_BEGIN IDENTIFIER GREATER struct_body STRUCT_END;

struct_body: struct_member struct_body
    | %empty
    ;

struct_member: LET IDENTIFIER COLON type SEMICOLON
    | LET IDENTIFIER COLON type ASSIGN expression SEMICOLON
    ;

function_declaration: FUNCTION_BEGIN FUNCTION_NAME LEFT_PARENTHESIS params RIGHT_PARENTHESIS COLON type GREATER body FUNCTION_END
    | FUNCTION_BEGIN FUNCTION_NAME LEFT_PARENTHESIS params RIGHT_PARENTHESIS COLON VOID GREATER body FUNCTION_END
    ;

params: param_list
    | %empty
    ;

param_list: IDENTIFIER COLON type COMMA param_list
    | IDENTIFIER COLON type
    ;

main: FUNCTION_BEGIN MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON VOID GREATER body FUNCTION_END;

body: statement_list;

statement_list: statement statement_list
    | %empty
    ;

statement: WRITE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON
    | READ LEFT_PARENTHESIS IDENTIFIER RIGHT_PARENTHESIS SEMICOLON
    | IF_BEGIN condition GREATER body IF_END
    | IF_BEGIN condition GREATER body ELSE body IF_END
    | WHILE_BEGIN condition GREATER body WHILE_END
    | assignment SEMICOLON
    ;

assignment: IDENTIFIER ASSIGN expression
    | array_assignment
    ;

array_assignment: IDENTIFIER LEFT_BRACKET expression RIGHT_BRACKET ASSIGN expression;

condition: expression EQUAL expression
    | expression NOT_EQUAL expression
    | expression LESS expression
    | expression GREATER expression
    | expression LESS_OR_EQUAL expression
    | expression GREATER_OR_EQUAL expression
    | expression OR expression
    | expression AND expression
    | NOT expression
    | %empty
    ;

expression: INTEGER_LITERAL
    | FLOAT_LITERAL
    | STRING_LITERAL
    | BOOLEAN_LITERAL
    | IDENTIFIER
    | array_access
    | expression PLUS expression
    | expression MINUS expression
    | expression MULTIPLY expression
    | expression DIVIDE expression
    | expression MODULO expression
    ;

array_access: IDENTIFIER LEFT_BRACKET expression RIGHT_BRACKET;

%%

/* *** *** section de code *** *** */

int yyerror(const char *error_message) {
    printf("File \"%s\", line %d, character %d: Syntax Error, unexpected token '%s'\n", filename, yylineno, column_counter, yytext);
}

int checkTypeCompatibility(char *varType, char *exprType) {
    
    if (strcmp(varType, exprType) == 0) {
        return 1; // Types compatibles
    }
    // Ajoutez d'autres vérifications de compatibilité si nécessaire
    return 0; // Types incompatibles
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
