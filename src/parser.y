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
#include "syntax_tree.h"


void yyerror(const char *);


extern int column_counter;

char *filename;
SymbolsTableStack symbolsTableStack;
SyntaxTree syntaxTree;

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
    void *node_t;
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
%nonassoc EQUAL NOT_EQUAL
%nonassoc LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right NEG
%right NOT


%type <node_t> program
%type <node_t> code_list
%type <node_t> code

%type <node_t> main_function
%type <node_t> function_definition
%type <node_t> function_signature
%type <node_t> parameter_list
%type <node_t> parameter
%type <node_t> return_type
%type <node_t> function_call
%type <node_t> argument_list

%type <node_t> struct_definition
%type <node_t> struct_body
%type <node_t> field_definition

%type <node_t> variable_definition
%type <node_t> variable_initialisation
%type <node_t> initialisation_expression

%type <node_t> type
%type <node_t> struct_type
%type <node_t> array_type

%type <node_t> variable
%type <node_t> literal

%type <node_t> struct_literal
%type <node_t> struct_field_list
%type <node_t> struct_field

%type <node_t> array_literal
%type <node_t> array_values

%type <node_t> statement_list
%type <node_t> statement
%type <node_t> write_statement
%type <node_t> read_statement
%type <node_t> assign_statement
%type <node_t> return_statement
%type <node_t> call_statement
%type <node_t> if_statement
%type <node_t> while_statement

%type <node_t> condition
%type <node_t> calculation
%type <node_t> expression

%type <node_t> scope_begin scope_end
%type <node_t> block



/* *** *** section des actions *** *** */

%start program

%%

/* program structure */

program
    : HTPL_BEGIN code_list main_function HTPL_END {
        $$ = createNode(&syntaxTree, "program");
        syntaxTree.root = $$;
        addChildren($$, 2, $2, $3);
    }
;

code_list
    : code_list code {
        $$ = $1 ? $1 : createNode(&syntaxTree, "code_list");
        addChildren($$, 1, $2);
    }
    | %empty {
        $$ = NULL;
    }
;

code
    : function_definition {
        $$ = $1;
    }
    | struct_definition {
        $$ = $1;
    }
    | variable_definition {
        $$ = $1;
    }
    | variable_initialisation {
        $$ = $1;
    }
;


/* function rules */

main_function
    : FUNCTION_BEGIN MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON VOID block FUNCTION_END {
        $$ = createNode(&syntaxTree, "main_function");
        addChildren($$, 1, $7);

        // todo 2 : create entry in the symbols table
        SymbolsTable *symbolsTable = getCurrentScope(&symbolsTableStack);
        Symbol *symbol = createSymbol(symbolsTable, symbolsTable->size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
    }
;

function_definition
    : FUNCTION_BEGIN FUNCTION_NAME function_signature block FUNCTION_END {
        $$ = createNode(&syntaxTree, "function_definition");
        addChildren($$, 2, $3, $4);

        // todo 4 : create entry in the symbols table
        SymbolsTable *symbolsTable = getCurrentScope(&symbolsTableStack);
        Symbol *symbol = createSymbol(symbolsTable, symbolsTable->size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
    }
;

function_signature
    : LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON return_type {
        $$ = createNode(&syntaxTree, "function_signature");
        addChildren($$, 1, $4);
    }
    | LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS COLON return_type {
        $$ = createNode(&syntaxTree, "function_signature");
        addChildren($$, 2, $2, $5);
    }
;

parameter_list
    : parameter_list COMMA parameter {
        $$ = $1;
        addChildren($$, 1, $3);
    }
    | parameter {
        $$ = createNode(&syntaxTree, "parameter_list");
        addChildren($$, 1, $1);
    }
;

parameter
    : IDENTIFIER COLON type {
        $$ = createNode(&syntaxTree, "parameter");
        addChildren($$, 1, $3);
    }
;

return_type
    : type {
        $$ = createNode(&syntaxTree, "return_type");
        addChildren($$, 1, $1);
    }
    | VOID {
        $$ = createNode(&syntaxTree, "return_type");
    }
;

function_call
    : FUNCTION_NAME LEFT_PARENTHESIS RIGHT_PARENTHESIS {
        $$ = createNode(&syntaxTree, "function_call");
    }
    | FUNCTION_NAME LEFT_PARENTHESIS argument_list RIGHT_PARENTHESIS {
        $$ = createNode(&syntaxTree, "function_call");
        addChildren($$, 1, $3);
    }
;

argument_list
    : argument_list COMMA expression {
        $$ = $1;
        addChildren($$, 1, $3);
    }
    | expression {
        $$ = createNode(&syntaxTree, "argument_list");
        addChildren($$, 1, $1);
    }
;


/* struct rules */

struct_definition
    : STRUCT_BEGIN IDENTIFIER GREATER struct_body STRUCT_END {
        $$ = createNode(&syntaxTree, "struct_definition");
        addChildren($$, 1, $4);

        // todo 3 : create entry in the symbols table
        SymbolsTable *symbolsTable = getCurrentScope(&symbolsTableStack);
        Symbol *symbol = createSymbol(symbolsTable, symbolsTable->size + 1, $2);
        createAttribute(&symbol->attributes, "category", "struct");
    }
;

struct_body
    : struct_body field_definition {
        $$ = $1;
        addChildren($$, 1, $2);
    }
    | field_definition {
        $$ = createNode(&syntaxTree, "struct_body");
        addChildren($$, 1, $1);
    }
;

field_definition
    : LET IDENTIFIER COLON type SEMICOLON {
        $$ = createNode(&syntaxTree, "field_definition");
        addChildren($$, 1, $4);
    }
;


/* variable rules */

variable_definition
    : LET IDENTIFIER COLON type SEMICOLON {
        $$ = createNode(&syntaxTree, "variable_definition");
        addChildren($$, 1, $4);

        // todo 1 : create entry in the symbols table
        SymbolsTable *symbolsTable = getCurrentScope(&symbolsTableStack);
        Symbol *symbol = createSymbol(symbolsTable, symbolsTable->size + 1, $2);
        createAttribute(&symbol->attributes, "category", "variable");
    }
;

variable_initialisation
    : LET IDENTIFIER COLON type ASSIGN initialisation_expression SEMICOLON {
        $$ = createNode(&syntaxTree, "variable_initialisation");
        addChildren($$, 2, $4, $6);

        // todo 5 : create entry in the symbols table
        SymbolsTable *symbolsTable = getCurrentScope(&symbolsTableStack);
        Symbol *symbol = createSymbol(symbolsTable, symbolsTable->size + 1, $2);
        createAttribute(&symbol->attributes, "category", "variable");
    }
;

initialisation_expression
    : expression {
        $$ = $1;
    }
    | array_literal {
        $$ = $1;
    }
    | struct_literal {
        $$ = $1;
    }
;


/* type rules */

type
    : TYPE_INTEGER {
        $$ = createNode(&syntaxTree, "type");
    }
    | TYPE_FLOAT {
        $$ = createNode(&syntaxTree, "type");
    }
    | TYPE_BOOLEAN {
        $$ = createNode(&syntaxTree, "type");
    }
    | TYPE_CHAR {
        $$ = createNode(&syntaxTree, "type");
    }
    | TYPE_STRING {
        $$ = createNode(&syntaxTree, "type");
    }
    | struct_type {
        $$ = createNode(&syntaxTree, "type");
        addChildren($$, 1, $1);
    }
    | array_type {
        $$ = createNode(&syntaxTree, "type");
        addChildren($$, 1, $1);
    }
;

struct_type
    : IDENTIFIER {
        $$ = createNode(&syntaxTree, "struct_type");
    }
;

array_type
    : type LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET {
        $$ = createNode(&syntaxTree, "array_type");
        addChildren($$, 1, $1);
    }
;


/* variable access rules */

variable
    : variable DOT IDENTIFIER {
        $$ = createNode(&syntaxTree, "variable");
        addChildren($$, 1, $1);
    }
    | variable LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET {
        $$ = createNode(&syntaxTree, "variable");
        addChildren($$, 1, $1);
    }
    | IDENTIFIER {
        $$ = createNode(&syntaxTree, "variable");
    }
;

literal
    : INTEGER_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
    }
    | FLOAT_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
    }
    | BOOLEAN_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
    }
    | CHAR_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
    }
    | STRING_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
    }
;


/* struct literals */

struct_literal
    : LEFT_BRACE struct_field_list RIGHT_BRACE {
        $$ = createNode(&syntaxTree, "struct_literal");
        addChildren($$, 1, $2);
    }
;

struct_field_list
    : struct_field_list COMMA struct_field {
        $$ = $1;
        addChildren($$, 1, $3);
    }
    | struct_field {
        $$ = createNode(&syntaxTree, "struct_field_list");
        addChildren($$, 1, $1);
    }
;

struct_field
    : IDENTIFIER ASSIGN expression {
        $$ = createNode(&syntaxTree, "struct_field");
        addChildren($$, 1, $3);
    }
;


/* array literals */

array_literal
    : LEFT_BRACKET array_values RIGHT_BRACKET {
        $$ = $2;
    }
;

array_values
    : array_values COMMA expression {
        $$ = $1;
        addChildren($$, 1, $3);
    }
    | expression {
        $$ = createNode(&syntaxTree, "array_values");
        addChildren($$, 1, $1);
    }
;


/* statement rules */

statement_list
    : statement_list statement {
        $$ = $1;
        addChildren($$, 1, $2);
    }
    | statement {
        $$ = createNode(&syntaxTree, "statement_list");
        addChildren($$, 1, $1);
    }
;

statement
    : variable_definition {
        $$ = $1;
    }
    | variable_initialisation {
        $$ = $1;
    }
    | write_statement {
        $$ = $1;
    }
    | read_statement {
        $$ = $1;
    }
    | assign_statement {
        $$ = $1;
    }
    | return_statement {
        $$ = $1;
    }
    | call_statement {
        $$ = $1;
    }
    | if_statement {
        $$ = $1;
    }
    | while_statement {
        $$ = $1;
    }
;

write_statement
    : WRITE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
        $$ = createNode(&syntaxTree, "write_statement");
        addChildren($$, 1, $3);
    }
;

read_statement
    : READ LEFT_PARENTHESIS variable RIGHT_PARENTHESIS SEMICOLON {
        $$ = createNode(&syntaxTree, "read_statement");
        addChildren($$, 1, $3);
    }
;

assign_statement
    : variable ASSIGN expression SEMICOLON {
        $$ = createNode(&syntaxTree, "assign_statement");
        addChildren($$, 2, $1, $3);
    }
;

return_statement
    : RETURN expression SEMICOLON {
        $$ = createNode(&syntaxTree, "return_statement");
        addChildren($$, 1, $2);
    }
;

call_statement
    : function_call SEMICOLON {
        $$ = createNode(&syntaxTree, "call_statement");
        addChildren($$, 1, $1);
    }
;

if_statement
    : IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS block IF_END {
        $$ = createNode(&syntaxTree, "if_statement");
        addChildren($$, 2, $3, $5);
    }
    | IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS block ELSE block IF_END {
        $$ = createNode(&syntaxTree, "if_statement");
        addChildren($$, 3, $3, $5, $7);
    }
;

while_statement
    : WHILE_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS block WHILE_END {
        $$ = createNode(&syntaxTree, "while_statement");
        addChildren($$, 2, $3, $5);
    }
;


/* expression rules */

condition
    : calculation EQUAL calculation {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | calculation NOT_EQUAL calculation {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | calculation LESS calculation {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | calculation LESS_OR_EQUAL calculation {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | calculation GREATER calculation {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | calculation GREATER_OR_EQUAL calculation {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | LEFT_PARENTHESIS condition RIGHT_PARENTHESIS {
        $$ = $2;
    }
    | condition AND condition {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | condition OR condition {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 2, $1, $3);
    }
    | NOT condition {
        $$ = createNode(&syntaxTree, "condition");
        addChildren($$, 1, $2);
    }
;

calculation
    : literal {
        $$ = $1;
    }
    | variable {
        $$ = $1;
    }
    | function_call {
        $$ = $1;
    }
    | LEFT_PARENTHESIS calculation RIGHT_PARENTHESIS {
        $$ = $2;
    }
    | calculation PLUS calculation {
        $$ = createNode(&syntaxTree, "calculation");
        addChildren($$, 2, $1, $3);
    }
    | calculation MINUS calculation {
        $$ = createNode(&syntaxTree, "calculation");
        addChildren($$, 2, $1, $3);
    }
    | calculation MULTIPLY calculation {
        $$ = createNode(&syntaxTree, "calculation");
        addChildren($$, 2, $1, $3);
    }
    | calculation DIVIDE calculation {
        $$ = createNode(&syntaxTree, "calculation");
        addChildren($$, 2, $1, $3);
    }
    | calculation MODULO calculation {
        $$ = createNode(&syntaxTree, "calculation");
        addChildren($$, 2, $1, $3);
    }
    | MINUS calculation %prec NEG {
        $$ = createNode(&syntaxTree, "calculation");
        addChildren($$, 1, $2);
    }
;

expression
    : calculation {
        $$ = $1;
    }
    | condition {
        $$ = $1;
    }
;


/* scope rules */

scope_begin
    : GREATER {
        $$ = NULL;
        pushScope(&symbolsTableStack);
    }
;

scope_end
    : LESS {
        $$ = NULL;

        printf("\n");
        printAllScopes(&symbolsTableStack);
        printf("\n");

        SymbolsTable *symbolsTable = popScope(&symbolsTableStack);
        deleteSymbolsTable(symbolsTable);
        free(symbolsTable);
    }
;

block
    : scope_begin statement_list scope_end {
        $$ = $2;
    }
;

%%



/* *** *** section de code *** *** */

void yyerror(const char *error_message) {
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

    initializeSyntaxTree(&syntaxTree);
    initializeSymbolsTableStack(&symbolsTableStack);
    pushScope(&symbolsTableStack); // push the global scope symbols table to the stack

    int result = yyparse();

    fclose(file);

    printf("\n");
    printSyntaxTree(&syntaxTree);
    printf("\n");
    printf(">>> Printing the symbols table of the global scope\n");
    printAllScopes(&symbolsTableStack);
    printf("\n");

    deleteSyntaxTree(&syntaxTree);
    deleteSymbolsTableStack(&symbolsTableStack);

    if (result == 0) {
        printf("Parsing completed successfully!\n");
    } else if (result == 1) {
        printf("Parsing failed due to an error.\n");
    } else if (result == 2) {
        printf("Parsing failed due to memory exhaustion.\n");
    }

    return result;
}
