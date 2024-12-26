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


extern int column_counter;

char *filename;
SymbolsTable symbolsTable;

%}


%define lr.type lalr
%define parse.lac full
%define parse.error detailed


%union {
    int int_t;
    float float_t;
    bool boolean_t;
    char char_t;
    char *string_t;
}



/* *** *** section de déclaration *** *** */

%token TYPE_INTEGER TYPE_FLOAT TYPE_BOOLEAN TYPE_CHAR TYPE_STRING
%token VOID
%token <int_t>INTEGER_LITERAL <float_t>FLOAT_LITERAL <boolean_t>BOOLEAN_LITERAL <char_t>CHAR_LITERAL <string_t>STRING_LITERAL

%token PLUS MINUS MULTIPLY DIVIDE MODULO
%token AND OR NOT
%token EQUAL NOT_EQUAL LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL

%token LEFT_PARENTHESIS RIGHT_PARENTHESIS
%token LEFT_BRACE RIGHT_BRACE
%token LEFT_BRACKET RIGHT_BRACKET

%token COLON SEMICOLON DOT COMMA
%token RETURN ASSIGN LET <string_t>IDENTIFIER

%token HTPL_BEGIN HTPL_END
%token FUNCTION_BEGIN FUNCTION_END <string_t>FUNCTION_NAME <string_t>MAIN READ WRITE
%token IF_BEGIN IF_END ELSE
%token WHILE_BEGIN WHILE_END
%token STRUCT_BEGIN STRUCT_END



%nonassoc ASSIGN

%left OR
%left AND
%left EQUAL NOT_EQUAL
%left LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%left NEG
%left NOT



/* *** *** section des actions *** *** */

%start program

%%

/* program structure */

program
    : HTPL_BEGIN code_list main_function HTPL_END
;

code_list
    : code_list code
    | %empty
;

code
    : function_definition
    | struct_definition
    | variable_definition
    | variable_initialisation
;


/* function rules */

main_function
    : FUNCTION_BEGIN MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON VOID GREATER function_body FUNCTION_END {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
        createAttribute(&symbol->attributes, "entry", "true");
    }
;

function_definition
    : FUNCTION_BEGIN FUNCTION_NAME function_signature GREATER function_body FUNCTION_END {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
        createAttribute(&symbol->attributes, "entry", "false");
    }
;

function_signature
    : LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON return_type
    | LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS COLON return_type
;

parameter_list
    : parameter_list COMMA parameter
    | parameter
;

parameter
    : IDENTIFIER COLON type
;

return_type
    : type
    | VOID
;

function_body
    : statement_list
;

function_call
    : FUNCTION_NAME LEFT_PARENTHESIS argument_list RIGHT_PARENTHESIS
;

argument_list
    : argument_list COMMA variable
    | variable
;


/* struct rules */

struct_definition
    : STRUCT_BEGIN IDENTIFIER GREATER struct_body STRUCT_END {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "struct");
    }
;

struct_body
    : struct_body field_definition
    | field_definition
;

field_definition
    : LET IDENTIFIER COLON type SEMICOLON
;


/* variable rules */

variable_definition
    : LET IDENTIFIER COLON type SEMICOLON {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "variable");
        createAttribute(&symbol->attributes, "is_initialised", "false");
    }
;

variable_initialisation
    : LET IDENTIFIER COLON type ASSIGN initialisation_expression SEMICOLON {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "variable");
        createAttribute(&symbol->attributes, "is_initialised", "true");
    }
;

initialisation_expression
    : expression
    | array_literal
    | struct_literal
;


/* type rules */

type
    : TYPE_INTEGER
    | TYPE_FLOAT
    | TYPE_BOOLEAN
    | TYPE_CHAR
    | TYPE_STRING
    | struct_type
    | array_type
;

struct_type
    : IDENTIFIER
;

array_type
    : type LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
;


/* variable access rules */

variable
    : variable DOT IDENTIFIER
    | variable LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET
    | IDENTIFIER
;

literal
    : INTEGER_LITERAL
    | FLOAT_LITERAL
    | BOOLEAN_LITERAL
    | CHAR_LITERAL
    | STRING_LITERAL
;


/* struct literals */

struct_literal
    : LEFT_BRACE struct_field_list RIGHT_BRACE
;

struct_field_list
    : struct_field_list COMMA struct_field
    | struct_field
;

struct_field
    : IDENTIFIER ASSIGN expression
;


/* array literals */

array_literal
    : LEFT_BRACKET array_values RIGHT_BRACKET
;

array_values
    : array_values COMMA expression
    | expression
;


/* statement rules */

statement_list
    : statement_list statement
    | statement
;

statement
    : variable_definition
    | variable_initialisation
    | write_statement
    | read_statement
    | assign_statement
    | return_statement
    | call_statement
    | if_statement
    | while_statement
;

write_statement
    : WRITE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON
;

read_statement
    : READ LEFT_PARENTHESIS variable RIGHT_PARENTHESIS SEMICOLON
;

assign_statement
    : variable ASSIGN expression SEMICOLON
;

return_statement
    : RETURN expression SEMICOLON
;

call_statement
    : function_call SEMICOLON
;

if_statement
    : IF_BEGIN LEFT_PARENTHESIS expression RIGHT_PARENTHESIS GREATER statement_list IF_END
    | IF_BEGIN LEFT_PARENTHESIS expression RIGHT_PARENTHESIS GREATER statement_list ELSE statement_list IF_END
;

while_statement
    : WHILE_BEGIN LEFT_PARENTHESIS expression RIGHT_PARENTHESIS GREATER statement_list WHILE_END
;


/* expression rules */

expression
    : literal
    | variable
    | function_call
    | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS
    | expression PLUS expression
    | expression MINUS expression
    | MINUS expression %prec NEG
    | expression MULTIPLY expression
    | expression DIVIDE expression
    | expression MODULO expression
    | expression AND expression
    | expression OR expression
    | NOT expression
    | expression EQUAL expression
    | expression NOT_EQUAL expression
    | expression LESS expression
    | expression LESS_OR_EQUAL expression
    | expression GREATER expression
    | expression GREATER_OR_EQUAL expression
;

%%



/* *** *** section de code *** *** */

int yyerror(const char *error_message) {
    printf("File \"%s\", line %d, character %d: %s\n", filename, yylineno, column_counter, error_message);
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

    int result = yyparse();

    fclose(file);

    printf("\n");
    printSymbolsTable(&symbolsTable);
    printf("\n");

    deleteSymbolsTable(&symbolsTable);

    if (result == 0) {
        printf("Parsing completed successfully!\n");
    } else if (result == 1) {
        printf("Parsing failed due to an error.\n");
    } else if (result == 2) {
        printf("Parsing failed due to memory exhaustion.\n");
    }

    return result;
}
