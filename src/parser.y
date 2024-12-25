/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <math.h>

#include "lexer.h"
#include "symbols_table.h"
#include "tree.h"

int yylex();
int yyerror(const char *);

extern char *filename;
extern int column_counter;
extern SymbolsTable symbolsTable;

%}

/* definition des types de donnees */
%union {
    Node *node;
    char *string;
    int integer;
    float floating;
    char character;
}

/* *** *** section de déclaration *** *** */

/* declaration des tokens avec leurs types */
%token <string> IDENTIFIER STRING_LITERAL FUNCTION_NAME
%token <integer> INTEGER_LITERAL BOOLEAN_LITERAL
%token <floating> FLOAT_LITERAL
%token <character> CHAR_LITERAL
%token LET RETURN WRITE READ IF_BEGIN IF_END ELSE WHILE_BEGIN WHILE_END
%token PLUS MINUS MULTIPLY DIVIDE MODULO ASSIGN
%token AND OR NOT
%token EQUAL NOT_EQUAL LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS
%token LEFT_BRACE RIGHT_BRACE
%token LEFT_BRACKET RIGHT_BRACKET
%token SEMICOLON COLON DOT COMMA
%token STRUCT_BEGIN STRUCT_END HTPL_BEGIN HTPL_END
%token FUNCTION_BEGIN FUNCTION_END MAIN
%token TYPE_INTEGER TYPE_FLOAT TYPE_BOOLEAN TYPE_STRING TYPE_CHAR VOID

 /* Types de non-terminaux */
%type <node> program declaration_list declaration function_list function main_function
%type <node> signature parameter_list parameter return_type
%type <node> statement_list statement write_statement read_statement return_statement
%type <node> let_statement if_statement while_statement struct_statement
%type <node> struct_body expression term factor condition type

 /* definition des priorite des operateurs */
%left OR
%left AND
%nonassoc EQUAL NOT_EQUAL
%left LESS GREATER
%left PLUS MINUS
%left MULTIPLY DIVIDE

/* *** *** section des actions *** *** */
 
%start program

%%

 /* program principal */
program:
    HTPL_BEGIN declaration_list function_list main_function HTPL_END {
        $$ = createNode("Program", 3, $2, $3, $4);
        printf("Parsing completed successfully.\n");
        printTree($$, 0);
    }
;
 
 /* declarations (liste de variables) */
declaration_list:
    declaration_list declaration {
        $$ = createNode("DeclarationList", 2, $1, $2);
    }
  | %empty {
        $$ = createNode("EmptyDeclarationList", 0);
    }
;

declaration:
    LET IDENTIFIER COLON type ASSIGN expression SEMICOLON {
        $$ = createNode("Declaration", 3, createNode($2, 0), $4, $6);
    }
;

 /* liste des fonctions */
function_list:
    function_list function {
        $$ = createNode("FunctionList", 2, $1, $2);
    }
  | %empty {
        $$ = createNode("EmptyFunctionList", 0);
    }
;

function:
    FUNCTION_BEGIN signature LEFT_BRACE statement_list RIGHT_BRACE FUNCTION_END {
        $$ = createNode("Function", 2, $2, $4);
    }
;

signature:
    FUNCTION_NAME LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS COLON return_type {
        $$ = createNode("Signature", 3, createNode($1, 0), $3, $6);
    }
;

parameter_list:
    parameter_list COMMA parameter {
        $$ = createNode("ParameterList", 2, $1, $3);
    }
  | parameter {
        $$ = createNode("ParameterList", 1, $1);
    }
  | %empty {
        $$ = createNode("EmptyParameterList", 0);
    }
;

parameter:
    IDENTIFIER COLON type {
        $$ = createNode("Parameter", 2, createNode($1, 0), $3);
    }
;

return_type:
    type {
        $$ = $1;
    }
  | VOID {
        $$ = createNode("Void", 0);
    }
;

 /* fonction main */
main_function:
    FUNCTION_BEGIN MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON VOID LEFT_BRACE statement_list RIGHT_BRACE FUNCTION_END {
        $$ = createNode("MainFunction", 1, $8);
    }
;

 /* instructions (pouvant etre vide) */
statement_list:
    statement_list statement {
        $$ = createNode("StatementList", 2, $1, $2);
    }
  | %empty {
        $$ = createNode("EmptyStatementList", 0);
    }
;

statement:
    write_statement
  | read_statement
  | return_statement
  | let_statement
  | if_statement
  | while_statement
  | struct_statement
;

 /* Types */
type:
    TYPE_INTEGER {
        $$ = createNode("IntegerType", 0);
    }
  | TYPE_FLOAT {
        $$ = createNode("FloatType", 0);
    }
  | TYPE_BOOLEAN {
        $$ = createNode("BooleanType", 0);
    }
  | TYPE_STRING {
        $$ = createNode("StringType", 0);
    }
  | TYPE_CHAR {
        $$ = createNode("CharType", 0);
    }
;
 
 /* instructions specifiques */
write_statement:
    WRITE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
        $$ = createNode("Write", 1, $3);
    }
;

read_statement:
    READ LEFT_PARENTHESIS IDENTIFIER RIGHT_PARENTHESIS SEMICOLON {
        $$ = createNode("Read", 1, createNode($3, 0));
    }
;

return_statement:
    RETURN expression SEMICOLON {
        $$ = createNode("Return", 1, $2);
    }
;

let_statement:
    LET IDENTIFIER COLON type ASSIGN expression SEMICOLON {
        $$ = createNode("Let", 3, createNode($2, 0), $4, $6);
    }
;
 
if_statement:
    IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS LEFT_BRACE statement_list RIGHT_BRACE ELSE LEFT_BRACE statement_list RIGHT_BRACE {
        $$ = createNode("If-Else", 3, $3, $6, $10);
    }
;
 
while_statement:
    WHILE_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS LEFT_BRACE statement_list RIGHT_BRACE {
        $$ = createNode("While", 2, $3, $6);
    }
;
 
struct_statement:
    STRUCT_BEGIN IDENTIFIER LEFT_BRACE struct_body RIGHT_BRACE STRUCT_END {
        $$ = createNode("Struct", 2, createNode($2, 0), $4);
    }
;

struct_body:
    declaration_list {
        $$ = createNode("StructBody", 1, $1);
    }
;

 /* expressions */
expression:
    expression PLUS term {
        $$ = createNode("Add", 2, $1, $3);
    }
  | expression MINUS term {
        $$ = createNode("Subtract", 2, $1, $3);
    }
  | term {
        $$ = $1;
    }
;

term:
    term MULTIPLY factor {
        $$ = createNode("Multiply", 2, $1, $3);
    }
  | term DIVIDE factor {
        $$ = createNode("Divide", 2, $1, $3);
    }
  | factor {
        $$ = $1;
    }
;

factor:
    INTEGER_LITERAL {
        char buffer[32];
        sprintf(buffer, "%d", $1); 
        $$ = createNode("Integer", 1, createNode(buffer, 0));
    }
  | IDENTIFIER {
        $$ = createNode("Identifier", 1, createNode($1, 0));
    }
  | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS {
        $$ = $2;
    }
;

 /* Conditions */
condition:
    expression EQUAL expression {
        $$ = createNode("EqualCondition", 2, $1, $3);
    }
  | expression LESS expression {
        $$ = createNode("LessCondition", 2, $1, $3);
    }
;

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
