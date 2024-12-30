/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "parser.tab.h"
#include "symbols_table.h"
#include "syntax_tree.h"


void yyerror(const char *);
void function_declaration();
void function_signature();
void parameter();
void return_type();
void type_parameter();
int lookahead;

int yylex(void);

extern int column_counter;
extern int yylineno;

char *filename;
SymbolsTable symbolsTable;
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

%type <node_t> function_declaration
%type <node_t> type_parameter

%type <node_t> main_function
%type <node_t> function_signature
%type <node_t> parameter
%type <node_t> return_type
%type <node_t> function_body
%type <node_t> function_call

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



/* *** *** section des actions *** *** */

%start program

%%

/* program structure */

program
    : HTPL_BEGIN code_list main_function HTPL_END {
    }
;

code_list
    : code_list code {
       
    }
    | %empty {
        
    }
;

/*code
    : function_definition {
        $$ = createNode(&syntaxTree, "code");
        addChildren($$, 1, $1);
    }
    | struct_definition {
        $$ = createNode(&syntaxTree, "code");
        addChildren($$, 1, $1);
    }
    | variable_definition {
        $$ = createNode(&syntaxTree, "code");
        addChildren($$, 1, $1);
    }
    | variable_initialisation {
        $$ = createNode(&syntaxTree, "code");
        addChildren($$, 1, $1);
    }
;*/

code
    : function_declaration {
       
    }
    | struct_definition {
    
    }
    | variable_definition {
       
    }
    | variable_initialisation {
    }
;


/* function rules */

main_function
    : FUNCTION_BEGIN MAIN LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON VOID GREATER function_body FUNCTION_END {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
        createAttribute(&symbol->attributes, "entry", "true");

    }
;

/*function_definition
    : FUNCTION_BEGIN FUNCTION_NAME function_signature GREATER function_body FUNCTION_END {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
        createAttribute(&symbol->attributes, "entry", "false");

        $$ = createNode(&syntaxTree, "function_definition");
        addChildren($$, 2, $3, $5);
    }
;*/

// function_signature
//     : LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON return_type {
//         $$ = createNode(&syntaxTree, "function_signature");
//         addChildren($$, 1, $4);
//     }
//     | LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS COLON return_type {
//         $$ = createNode(&syntaxTree, "function_signature");
//         addChildren($$, 2, $2, $5);
//     }
// ;

// parameter_list
//     : parameter_list COMMA parameter {
//         $$ = createNode(&syntaxTree, "parameter_list");
//         addChildren($$, 2, $1, $3);
//     }
//     | parameter {
//         $$ = createNode(&syntaxTree, "parameter_list");
//         addChildren($$, 1, $1);
//     }
// ;

// parameter
//     : IDENTIFIER COLON type {
//         $$ = createNode(&syntaxTree, "parameter");
//         addChildren($$, 1, $3);
//     }
// ;

// return_type
//     : type {
//         $$ = createNode(&syntaxTree, "return_type");
//         addChildren($$, 1, $1);
//     }
//     | VOID {
//         $$ = createNode(&syntaxTree, "return_type");
//     }
// ;

/*************************************************/

function_declaration
    : FUNCTION_BEGIN FUNCTION_NAME function_signature GREATER{
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "function");
        createAttribute(&symbol->attributes, "entry", "false");
    }
; 

function_signature
    : LEFT_PARENTHESIS parameter RIGHT_PARENTHESIS COLON return_type { 
    }
;

parameter
    : IDENTIFIER COLON type_parameter {
       
    }
;

return_type
    : type_parameter {
      
    }
    | VOID {
    }
;

type_parameter
    : TYPE_INTEGER {
    }
    | TYPE_FLOAT {
    }
    | TYPE_BOOLEAN {
    }
    | TYPE_CHAR {
    }
    | TYPE_STRING {
    }
;


/**********************************************/

function_body
    : statement_list {
     
    }
;

// function_call
//     : FUNCTION_NAME LEFT_PARENTHESIS RIGHT_PARENTHESIS {
//         $$ = createNode(&syntaxTree, "function_call");
//     }
//     | FUNCTION_NAME LEFT_PARENTHESIS argument_list RIGHT_PARENTHESIS {
//         $$ = createNode(&syntaxTree, "function_call");
//         addChildren($$, 1, $3);
//     }
// ;

// argument_list
//     : argument_list COMMA expression {
//         $$ = createNode(&syntaxTree, "argument_list");
//         addChildren($$, 2, $1, $3);
//     }
//     | expression {
//         $$ = createNode(&syntaxTree, "argument_list");
//         addChildren($$, 1, $1);
//     }
// ;

function_call
    : FUNCTION_NAME LEFT_PARENTHESIS RIGHT_PARENTHESIS {
    }
;


/* struct rules */

struct_definition
    : STRUCT_BEGIN IDENTIFIER GREATER struct_body STRUCT_END {
        Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, $2);
        createAttribute(&symbol->attributes, "category", "struct");

    }
;

struct_body
    : struct_body field_definition {

    }
    | field_definition {

    }
;

field_definition
    : LET IDENTIFIER COLON type SEMICOLON {
    }
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
    : expression {
    }
    | array_literal {
      }
    | struct_literal {
    }
;


/* type rules */

type
    : TYPE_INTEGER {
    }
    | TYPE_FLOAT {
    }
    | TYPE_BOOLEAN {
    }
    | TYPE_CHAR {
    }
    | TYPE_STRING {
    }
    | struct_type {
    }
    | array_type {
    }
;

struct_type
    : IDENTIFIER {
    }
;

array_type
    : type LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET {
    }
;


/* variable access rules */

variable
    : variable DOT IDENTIFIER {

    }
    | variable LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET {

    }
    | IDENTIFIER {
    }
;

literal
    : INTEGER_LITERAL {
    }
    | FLOAT_LITERAL {
    }
    | BOOLEAN_LITERAL {
    }
    | CHAR_LITERAL {
    }
    | STRING_LITERAL {
    }
;


/* struct literals */

struct_literal
    : LEFT_BRACE struct_field_list RIGHT_BRACE {
    
    }
;

struct_field_list
    : struct_field_list COMMA struct_field {
     
    }
    | struct_field {
    }
;

struct_field
    : IDENTIFIER ASSIGN expression {

    }
;


/* array literals */

array_literal
    : LEFT_BRACKET array_values RIGHT_BRACKET {
   
    }
;

array_values
    : array_values COMMA expression {
   
    }
    | expression {
       
    }
;


/* statement rules */

statement_list
    : statement_list statement {
        
    }
    | statement {
        
    }
;

statement
    : variable_definition {
      
    }
    | variable_initialisation {
      
    }
    | write_statement {
        
    }
    | read_statement {
      
    }
    | assign_statement {
       
    }
    | return_statement {
       
    }
    | call_statement {
  
    }
    | if_statement {

    }
    | while_statement {
      
    }
;

write_statement
    : WRITE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS SEMICOLON {
     
    }
;

read_statement
    : READ LEFT_PARENTHESIS variable RIGHT_PARENTHESIS SEMICOLON {
    
    }
;

assign_statement
    : variable ASSIGN expression SEMICOLON {

    }
;

return_statement
    : RETURN expression SEMICOLON {
   
    }
;

call_statement
    : function_call SEMICOLON {
 
    }
;

if_statement
    : IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS GREATER statement_list IF_END {
  
    }
    | IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS GREATER statement_list ELSE statement_list IF_END {

    }
;

while_statement
    : WHILE_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS GREATER statement_list WHILE_END {
 
    }
;


/* expression rules */

condition
    : calculation EQUAL calculation {

    }
    | calculation NOT_EQUAL calculation {

    }
    | calculation LESS calculation {
  
    }
    | calculation LESS_OR_EQUAL calculation {
    
    }
    | calculation GREATER calculation {

    }
    | calculation GREATER_OR_EQUAL calculation {

    }
    | LEFT_PARENTHESIS condition RIGHT_PARENTHESIS {
   
    }
    | condition AND condition {
 
    }
    | condition OR condition {
    }
    | NOT condition {
 
    }
;

 calculation
     : literal {
    
     }
     | variable {

     }
     | function_call {
   
     }
     | LEFT_PARENTHESIS calculation RIGHT_PARENTHESIS {
  
     }
     | calculation PLUS calculation {

     }
     | calculation MINUS calculation {
 
     }
     | calculation MULTIPLY calculation {
  
     }
     | calculation DIVIDE calculation {
        
     }
     | calculation MODULO calculation {
    
     }
     | MINUS calculation %prec NEG {
    
     }
 ;

/* arithmetic grammar */

// calculation
//     : primary calculation_tail {
//         $$ = createNode(&syntaxTree, "calculation");
//         addChildren($$, 2, $1, $2);
//     }
// ;

// calculation_tail
//     : PLUS primary calculation_tail {
//         $$ = createNode(&syntaxTree, "calculation_tail");
//         addChildren($$, 2, $2, $3);
//     }
//     | MINUS primary calculation_tail {
//         $$ = createNode(&syntaxTree, "calculation_tail");
//         addChildren($$, 2, $2, $3);
//     }
//     | MULTIPLY primary calculation_tail {
//         $$ = createNode(&syntaxTree, "calculation_tail");
//         addChildren($$, 2, $2, $3);
//     }
//     | DIVIDE primary calculation_tail {
//         $$ = createNode(&syntaxTree, "calculation_tail");
//         addChildren($$, 2, $2, $3);
//     }
//     | MODULO primary calculation_tail {
//         $$ = createNode(&syntaxTree, "calculation_tail");
//         addChildren($$, 2, $2, $3);
//     }
//     | %empty {
//         $$ = createNode(&syntaxTree, "calculation_tail");
//     }
// ;

// primary
//     : literal {
//         $$ = createNode(&syntaxTree, "primary");
//         addChildren($$, 1, $1);
//     }
//     | variable {
//         $$ = createNode(&syntaxTree, "primary");
//         addChildren($$, 1, $1);
//     }
//     | function_call {
//         $$ = createNode(&syntaxTree, "primary");
//         addChildren($$, 1, $1);
//     }
//     | LEFT_PARENTHESIS calculation RIGHT_PARENTHESIS {
//         $$ = createNode(&syntaxTree, "primary");
//         addChildren($$, 1, $2);
//     }
//     | MINUS primary %prec NEG {
//         $$ = createNode(&syntaxTree, "primary");
//         addChildren($$, 1, $2);
//     }
// ;

 expression
    : calculation {
 
     }
     | condition {

     }
 ;

%%
/* Match helper function */
void match(int expectedToken) {
    if (lookahead == expectedToken) {
        lookahead = yylex();
    } else {
        fprintf(stderr, "Syntax error: Expected %d, found %d\n", expectedToken, lookahead);
        exit(1);
    }
}

/* Recursive Descent Parser Implementation */

void function_declaration() {
    if (lookahead == FUNCTION_BEGIN){
        match(FUNCTION_BEGIN);
        if (lookahead == FUNCTION_NAME){
            match (FUNCTION_NAME);
            function_signature();
            if (lookahead == GREATER){
                match (GREATER);
            }
        }
    }
}

void function_signature() {
    if (lookahead == LEFT_PARENTHESIS){
        match (LEFT_PARENTHESIS);
        if (lookahead ==RIGHT_PARENTHESIS){
            match (RIGHT_PARENTHESIS);
            if (lookahead == COLON){
                match(COLON);
                return_type();
            }
        }else{
            parameter();
            if (lookahead ==RIGHT_PARENTHESIS){
                match (RIGHT_PARENTHESIS);
                if (lookahead == COLON){
                    match(COLON);
                    return_type();
                }
            }
        }
    }
}

void parameter() {
    if (lookahead == IDENTIFIER){
        match (IDENTIFIER);
        if(lookahead == COLON){
            match(COLON);
            type_parameter();
        }
    }
}

void return_type(){
    if (lookahead == VOID){
        match (VOID);
    }else{
        type_parameter();
    }
}

void type_parameter(){
    if (lookahead == TYPE_INTEGER){
        match (TYPE_INTEGER);
    }else if (lookahead == TYPE_FLOAT){
        match (TYPE_FLOAT);
    }else if (lookahead == TYPE_BOOLEAN){
        match (TYPE_BOOLEAN);
    }else if (lookahead == TYPE_CHAR){
        match (TYPE_CHAR);
    }else if (lookahead == TYPE_STRING){
        match (TYPE_STRING);
    }
}



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
   lookahead = yylex(); 
   printf("Lookahead token: %d\n", lookahead);
   function_declaration();  

    // initializeSyntaxTree(&syntaxTree);
    // initializeSymbolsTable(&symbolsTable);

    // int result = yyparse();

    // fclose(file);

    // printf("\n");
    // printSyntaxTree(&syntaxTree);
    // printf("\n");
    // printSymbolsTable(&symbolsTable);
    // printf("\n");

    // deleteSyntaxTree(&syntaxTree);
    // deleteSymbolsTable(&symbolsTable);

    // if (result == 0) {
    //     printf("Parsing completed successfully!\n");
    // } else if (result == 1) {
    //     printf("Parsing failed due to an error.\n");
    // } else if (result == 2) {
    //     printf("Parsing failed due to memory exhaustion.\n");
    // }

    // return result;
}