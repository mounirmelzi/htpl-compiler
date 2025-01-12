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
#include "quadruplets.h"
#include "pile.h"


void yyerror(const char *);


extern int column_counter;

char *filename;
SymbolsTableStack symbolsTableStack;
SyntaxTree syntaxTree;

// Global variables for quadruples
pile * stack;
quad *quadList = NULL;  // Global list to store quadruples
int quadCounter = 0;    // Counter for quadruples

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

%token <string_t>TYPE_INTEGER <string_t>TYPE_FLOAT <string_t>TYPE_BOOLEAN <string_t>TYPE_CHAR <string_t>TYPE_STRING
%token <string_t>VOID
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


%type <string_t> type
%type <string_t> return_type

%type <node_t> program
%type <node_t> code_list
%type <node_t> code

%type <node_t> main_function
%type <node_t> function_definition
%type <node_t> parameter_list
%type <node_t> parameter
%type <node_t> function_call
%type <node_t> argument_list

%type <node_t> struct_definition
%type <node_t> struct_body
%type <node_t> field_definition

%type <node_t> variable_definition
%type <node_t> variable_initialisation
%type <node_t> initialisation_expression

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
%type <node_t> optional_else
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

        Symbol *symbol = createSymbol(getCurrentScope(&symbolsTableStack), $2, $6, FUNCTION);
        symbol->value.functionValue.params_size = 0;
        symbol->value.functionValue.params = NULL;
    }
;

function_definition
    : FUNCTION_BEGIN FUNCTION_NAME LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON return_type block FUNCTION_END {
        Symbol *symbol = searchSymbolInCurrentScope(&symbolsTableStack, $2);
        if (symbol != NULL) {
            char error[100];
            sprintf(error, "semantic error, function '%s' is already declared in current scope", $2);
            yyerror(error);
            YYERROR;
        }

        $$ = createNode(&syntaxTree, "function_definition");
        addChildren($$, 1, $7);

        symbol = createSymbol(getCurrentScope(&symbolsTableStack), $2, $6, FUNCTION);
        symbol->value.functionValue.params_size = 0;
        symbol->value.functionValue.params = NULL;
    }
    | FUNCTION_BEGIN FUNCTION_NAME LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS COLON return_type block FUNCTION_END {
        Symbol *symbol = searchSymbolInCurrentScope(&symbolsTableStack, $2);
        if (symbol != NULL) {
            char error[100];
            sprintf(error, "semantic error, function '%s' is already declared in current scope", $2);
            yyerror(error);
            YYERROR;
        }

        $$ = createNode(&syntaxTree, "function_definition");
        addChildren($$, 1, $8);

        Node *node = $4;

        symbol = createSymbol(getCurrentScope(&symbolsTableStack), $2, $7, FUNCTION);        
        symbol->value.functionValue.params_size = node->size;
        symbol->value.functionValue.params = (VariableDefinition *)malloc(sizeof(VariableDefinition) * node->size);
        for (int i = 0; i < node->size; i++) {
            symbol->value.functionValue.params[i].name = node->children[i]->data.variableDefinition.name;
            symbol->value.functionValue.params[i].type = node->children[i]->data.variableDefinition.type;
        }
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
        Node *node = createNode(&syntaxTree, "parameter");
        node->data.variableDefinition.name = $1;
        node->data.variableDefinition.type = $3; 
        $$ = node;
    }
;

return_type
    : type {
        $$ = $1;
    }
    | VOID {
        $$ = $1;
    }
;

function_call
    : FUNCTION_NAME LEFT_PARENTHESIS RIGHT_PARENTHESIS {
        $$ = createNode(&syntaxTree, "function_call");
        ((Node *)$$)->data.variableDefinition.name = strdup($1);

        Symbol *functionSymbol = searchSymbolInAllScopes(&symbolsTableStack, $1);
        if (functionSymbol == NULL || functionSymbol->category != FUNCTION) {
            char error[100];
            sprintf(error, "semantic error: Function %s is not declared.", $1);
            yyerror(error);
            YYERROR;
        }

        if (functionSymbol->value.functionValue.params_size != 0) {
            char error[100];
            sprintf(error, "semantic error: Function %s expects %d parameters, but 0 were provided.",$1, functionSymbol->value.functionValue.params_size);
            yyerror(error);
            YYERROR;
        }
    }
    | FUNCTION_NAME LEFT_PARENTHESIS argument_list RIGHT_PARENTHESIS {
        $$ = createNode(&syntaxTree, "function_call");
        ((Node *)$$)->data.variableDefinition.name = strdup($1);
        addChildren($$, 1, $3);

        Symbol *functionSymbol = searchSymbolInAllScopes(&symbolsTableStack, $1);
        if (functionSymbol == NULL || functionSymbol->category != FUNCTION) {
            char error[100];
            sprintf(error, "semantic error: Function %s is not declared.", $1);
            yyerror(error);
            YYERROR;
        }

        if (functionSymbol->value.functionValue.params_size != ((Node *)$3)->size) {
            char error[100];
            sprintf(error, "semantic error: Function %s expects %d parameters, but %d were provided.", $1, functionSymbol->value.functionValue.params_size, ((Node *)$3)->size);
            yyerror(error);
            YYERROR;
        }

        for (int i = 0; i < ((Node *)$3)->size; i++) {
            Node *argNode = ((Node *)$3)->children[i];
            VariableDefinition *param = &(functionSymbol->value.functionValue.params[i]);

            if (strcmp(param->type, argNode->data.variableDefinition.type) != 0) {
                char error[100];
                sprintf(error, "semantic error: Incompatible type for parameter %d. Expected %s, got %s.",
                        i + 1, param->type, argNode->data.variableDefinition.type);
                yyerror(error);
                YYERROR;
            }
        }
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
        Symbol *symbol = searchSymbolInCurrentScope(&symbolsTableStack, $2);
        if (symbol != NULL) {
            char error[100];
            sprintf(error, "semantic error, struct '%s' is already declared in current scope", $2);
            yyerror(error);
            YYERROR;
        }

        $$ = createNode(&syntaxTree, "struct_definition");

        Node *node = $4;

        symbol = createSymbol(getCurrentScope(&symbolsTableStack), $2, strdup("type"), STRUCT);
        symbol->value.structValue.fields_size = node->size;
        symbol->value.structValue.fields = (VariableDefinition *)malloc(sizeof(VariableDefinition) * node->size);
        for (int i = 0; i < node->size; i++) {
            symbol->value.structValue.fields[i].name = node->children[i]->data.variableDefinition.name;
            symbol->value.structValue.fields[i].type = node->children[i]->data.variableDefinition.type;
        }
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
        Node *node = createNode(&syntaxTree, "field_definition");
        node->data.variableDefinition.name = $2;
        node->data.variableDefinition.type = $4; 
        $$ = node;
    }
;


/* variable rules */

variable_definition
    : LET IDENTIFIER COLON type SEMICOLON {
        Symbol *symbol = searchSymbolInCurrentScope(&symbolsTableStack, $2);
        if (symbol != NULL) {
            char error[100];
            sprintf(error, "semantic error, variable '%s' is already declared in current scope", $2);
            yyerror(error);
            YYERROR;
        }

        $$ = createNode(&syntaxTree, "variable_definition");

        ((Node *)$$)->name = strdup($2); // Identifier name
        ((Node *)$$)->type = strdup($4);

        symbol = createSymbol(getCurrentScope(&symbolsTableStack), $2, $4, VARIABLE);
        symbol->value.variableValue.is_initialized = false;
        insererQuadreplet(&quadList, "DECLARE", $2, "", "", quadCounter);
        quadCounter++;
    }
;

variable_initialisation
    : LET IDENTIFIER COLON type ASSIGN initialisation_expression SEMICOLON {
        Symbol *symbol = searchSymbolInCurrentScope(&symbolsTableStack, $2);
        if (symbol != NULL) {
            char error[100];
            sprintf(error, "semantic error, variable '%s' is already declared in current scope", $2);
            yyerror(error);
            YYERROR;
        }

        $$ = createNode(&syntaxTree, "variable_initialisation");
        addChildren($$, 1, $6);

        symbol = createSymbol(getCurrentScope(&symbolsTableStack), $2, $4, VARIABLE);
        symbol->value.variableValue.is_initialized = true;

        if (strcmp($4, ((Node *)$6)->data.variableDefinition.type) == 0) {
            insererQuadreplet(&quadList, "ASSIGN", ((Node *)$6)->data.variableDefinition.name, "", $2, quadCounter);
            quadCounter++;
        } else {
            char error[100];
            sprintf(error,"\nERROR: Incompatible type with %s !\n", symbol->type);
            yyerror(error);
            YYERROR;
        }
    }
;


initialisation_expression
    : expression {
        $$ = $1;
        ((Node *)$$)->data.variableDefinition.type =((Node *)$1)->data.variableDefinition.type;
        ((Node *)$$)->data.variableDefinition.name =((Node *)$1)->data.variableDefinition.name;
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
        $$ = $1;
    }
    | TYPE_FLOAT {
        $$ = $1;
    }
    | TYPE_BOOLEAN {
        $$ = $1;
    }
    | TYPE_CHAR {
        $$ = $1;
    }
    | TYPE_STRING {
        $$ = $1;
    }
    | IDENTIFIER {
        Symbol *symbol = searchSymbolInAllScopes(&symbolsTableStack, $1);
        if (symbol == NULL) {
            char error[100];
            sprintf(error, "semantic error, undefined struct type '%s'", $1);
            yyerror(error);
            YYERROR;
        }

        if (symbol->category != STRUCT) {
            char error[100];
            sprintf(error, "semantic error, '%s' is not a struct", $1);
            yyerror(error);
            YYERROR;
        }

        $$ = $1;
    }
    | type LEFT_BRACKET INTEGER_LITERAL RIGHT_BRACKET {
        char type[2048];
        sprintf(type, "%s[%d]", $1, $3);
        $$ = strdup(type);
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
        Symbol *symbol = searchSymbolInAllScopes(&symbolsTableStack, $1);
        if (symbol == NULL) {
            char error[100];
            sprintf(error, "semantic error, undefined variable '%s'", $1);
            yyerror(error);
            YYERROR;
        }

        $$ = createNode(&syntaxTree, "variable");

        Symbol *symbol = searchSymbolInAllScopes(&symbolsTableStack, $1);
        if (symbol == NULL) {
            fprintf(stderr, "Error: Undefined variable '%s' at line %d\n", $1, yylineno);
            exit(EXIT_FAILURE);
        }

        ((Node *)$$)->name = strdup(symbol->name); 
        ((Node *)$$)->type = strdup(symbol->type);
        ((Node *)$$)->data.variableDefinition.type = symbol->type;
        ((Node *)$$)->data.variableDefinition.name = strdup($1);
    }
;

literal
    : INTEGER_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
        ((Node *)$$)->name = strdup("literal");
        ((Node *)$$)->type = strdup("int");
        ((Node *)$$)->data.variableDefinition.type = "int";
        char buffer[20]; 
        sprintf(buffer, "%d", $1); 
        ((Node *)$$)->data.variableDefinition.name = strdup(buffer);
    }
    | FLOAT_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
        ((Node *)$$)->name = strdup("literal");
        ((Node *)$$)->type = strdup("float");
        ((Node *)$$)->data.variableDefinition.type = "float";
        char buffer[20]; 
        sprintf(buffer, "%f", $1); 
        ((Node *)$$)->data.variableDefinition.name = strdup(buffer); 
    }
    | BOOLEAN_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
        ((Node *)$$)->name = strdup("literal");
        ((Node *)$$)->type = strdup("boolean");
        ((Node *)$$)->data.variableDefinition.type = "bool";
        char buffer[6]; 
        sprintf(buffer, "%s", $1 ? "true" : "false");
        ((Node *)$$)->data.variableDefinition.name = strdup(buffer); 
    }
    | CHAR_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
        ((Node *)$$)->name = strdup("literal");
        ((Node *)$$)->type = strdup("char");
        ((Node *)$$)->data.variableDefinition.type = "char";
        char buffer[2] = { $1, '\0' }; 
        ((Node *)$$)->data.variableDefinition.name = strdup(buffer); 
    }
    | STRING_LITERAL {
        $$ = createNode(&syntaxTree, "literal");
        ((Node *)$$)->name = strdup("literal");
        ((Node *)$$)->type = strdup("string");
        ((Node *)$$)->data.variableDefinition.type = "string";
        ((Node *)$$)->data.variableDefinition.name = strdup($1); 
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
        insererQuadreplet(&quadList, "WRITE", ((Node *)$3)->data.variableDefinition.name, "", "", quadCounter);
        quadCounter++;
    }
;

read_statement
    : READ LEFT_PARENTHESIS variable RIGHT_PARENTHESIS SEMICOLON {
        $$ = createNode(&syntaxTree, "read_statement");
        addChildren($$, 1, $3);
        insererQuadreplet(&quadList, "READ", ((Node *)$3)->data.variableDefinition.name, "", "", quadCounter);
        quadCounter++;
    }
;

assign_statement
    : variable ASSIGN expression SEMICOLON {
        $$ = createNode(&syntaxTree, "assign_statement");
        addChildren($$, 2, $1, $3);
        if (strcmp(((Node *)$1)->data.variableDefinition.type, ((Node *)$3)->data.variableDefinition.type) == 0) {
            insererQuadreplet(&quadList, "ASSIGN", ((Node *)$3)->data.variableDefinition.name, "", ((Node *)$1)->data.variableDefinition.name, quadCounter);
            quadCounter++;
        } else {
            char error[100];
            sprintf(error,"\nERROR: Incompatible type with %s !\n", ((Node *)$1)->data.variableDefinition.type);
            yyerror(error);
            YYERROR;
        }
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
        insererQuadreplet(&quadList, "CALL", ((Node *)$1)->data.variableDefinition.name, "", "", quadCounter);
        quadCounter++;
    }
;

if_statement
    : IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS {
        // jump to else if condition is false
        char tmp[30];
        sprintf(tmp, "R%d", quadCounter); 
        insererQuadreplet(&quadList, "BZ", tmp, "", "cond_result", quadCounter);
        empiler(stack, quadCounter); 
        quadCounter++;
    }
    block {
        // jump to end of if-else statement
        insererQuadreplet(&quadList, "BR", "", "", "", quadCounter);
        empiler(stack, quadCounter);  
        quadCounter++;
    }
    optional_else
    IF_END {
        // update BR to jump to the end of the if-else statement
        int brAddress = depiler(stack);  
        char endAddressStr[30];
        sprintf(endAddressStr, "%d", quadCounter);  
        updateQuadreplet(quadList, brAddress, endAddressStr);

        
        insererQuadreplet(&quadList, "label", "", "", "end_if_else", quadCounter);
        quadCounter++;

        if ($8 == NULL) {  // No else part
            $$ = createNode(&syntaxTree, "if_statement");
            addChildren($$, 2, $3, $6);
        } else {  // With else part
            $$ = createNode(&syntaxTree, "if_statement");
            addChildren($$, 3, $3, $6, $8);
        }
    }
;

optional_else
    : ELSE {
        insererQuadreplet(&quadList, "label", "", "", "else_block", quadCounter);
        quadCounter++;
        // Pop the BR instruction and save it
        int brAddress = depiler(stack);

        //  Pop the BZ instruction and update it
        int bzAddress = depiler(stack);
        char elseAddressStr[30];
        sprintf(elseAddressStr, "%d", quadCounter-1);  // Address of the else block
        updateQuadreplet(quadList, bzAddress, elseAddressStr);

        // Push the BR instruction back onto the stack
        empiler(stack, brAddress);
    }
    block {
        $$ = $3;  // Return the else block
    }
    | %empty {
        // Pop the BR instruction and save it
        int brAddress = depiler(stack);

        //Pop the BZ instruction and update it
        int bzAddress = depiler(stack);
        char endAddressStr[30];
        sprintf(endAddressStr, "%d", quadCounter);  
        updateQuadreplet(quadList, bzAddress, endAddressStr);

        // supprimer l'instr BR
        supprimerQuadruplet(&quadList, brAddress);
        $$ = NULL;  // No else block
    }
;


while_statement
    : WHILE_BEGIN {
        // empiler l'adresse de debut
        empiler(stack, quadCounter);
    }
    LEFT_PARENTHESIS condition RIGHT_PARENTHESIS {
           
            char tmp[10];
            sprintf(tmp, "R%d", quadCounter);  
            insererQuadreplet(&quadList, "BZ", tmp, "", "cond_result", quadCounter);
            empiler(stack, quadCounter);  // empiler quad
            quadCounter++;
       
    }
    block WHILE_END {
        
        int addrDebutWhile = depiler(stack);  
        int addrCondWhile = depiler(stack); 

        char adresseCondWhile[10];
        sprintf(adresseCondWhile, "%d", addrDebutWhile);
        insererQuadreplet(&quadList, "BR", adresseCondWhile, "", "", quadCounter);
        quadCounter++;

        // Update BZ 
        char adresse[30];
        sprintf(adresse, "%d", quadCounter);
        updateQuadreplet(quadList, addrDebutWhile, adresse);

        // quadruplet pour la fin du while loop
        insererQuadreplet(&quadList, "label", "", "", "end_while", quadCounter);
        quadCounter++;

        $$ = createNode(&syntaxTree, "while_statement");
        addChildren($$, 2, $4, $7);  
    }
;


/* expression rules */



condition
    : calculation EQUAL calculation {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "==", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation NOT_EQUAL calculation {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "!=", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation LESS calculation {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "<", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation LESS_OR_EQUAL calculation {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "<=", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation GREATER calculation {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, ">", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation GREATER_OR_EQUAL calculation {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, ">=", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | LEFT_PARENTHESIS condition RIGHT_PARENTHESIS {
        $$ = $2;
    }
    | condition AND condition {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "and", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | condition OR condition {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 2, $1, $3);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "or", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | NOT condition {
        Node *node = createNode(&syntaxTree, "condition");
        addChildren(node, 1, $2);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "not", ((Node *)$2)->name, "", tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
;


calculation
    : literal {
        $$ = $1;
        ((Node *)$$)->data.variableDefinition.type = ((Node *)$1)->data.variableDefinition.type;
        ((Node *)$$)->data.variableDefinition.name =((Node *)$1)->data.variableDefinition.name;
    }
    | variable {
        $$ = $1;
        ((Node *)$$)->data.variableDefinition.type = ((Node *)$1)->data.variableDefinition.type;
        ((Node *)$$)->data.variableDefinition.name =((Node *)$1)->data.variableDefinition.name;
    }
    | function_call {
        $$ = $1;
        ((Node *)$$)->data.variableDefinition.type = ((Node *)$1)->data.variableDefinition.type;
        ((Node *)$$)->data.variableDefinition.name =((Node *)$1)->data.variableDefinition.name;
    }
    | LEFT_PARENTHESIS calculation RIGHT_PARENTHESIS {
        $$ = $2;
        ((Node *)$$)->data.variableDefinition.name =((Node *)$2)->data.variableDefinition.name;
    }
    | calculation PLUS calculation {
        Node *node = createNode(&syntaxTree, "calculation");
        addChildren(node, 2, $1, $3);

        checkTypeCompatibility(((Node*)$1)->type, ((Node*)$3)->type);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "+", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation MINUS calculation {
        Node *node = createNode(&syntaxTree, "calculation");
        addChildren(node, 2, $1, $3);

        checkTypeCompatibility(((Node*)$1)->type, ((Node*)$3)->type);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "-", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation MULTIPLY calculation {
        Node *node = createNode(&syntaxTree, "calculation");
        addChildren(node, 2, $1, $3);

        checkTypeCompatibility(((Node*)$1)->type, ((Node*)$3)->type);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "*", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation DIVIDE calculation {
        Node *node = createNode(&syntaxTree, "calculation");
        addChildren(node, 2, $1, $3);

        checkTypeCompatibility(((Node*)$1)->type, ((Node*)$3)->type);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "/", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | calculation MODULO calculation {
        Node *node = createNode(&syntaxTree, "calculation");
        addChildren(node, 2, $1, $3);

        checkTypeCompatibility(((Node*)$1)->type, ((Node*)$3)->type);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "%", ((Node *)$1)->name, ((Node *)$3)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
    | MINUS calculation %prec NEG {
        Node *node = createNode(&syntaxTree, "calculation");
        addChildren(node, 1, $2);

        char tmp[10];
        sprintf(tmp, "R%d", quadCounter);  
        insererQuadreplet(&quadList, "-", "0", ((Node *)$2)->name, tmp, quadCounter);
        quadCounter++;

        $$ = (void *)node;
    }
;

expression
    : calculation {
        $$ = $1;
        ((Node *)$$)->data.variableDefinition.type = ((Node *)$1)->data.variableDefinition.type;
        ((Node *)$$)->data.variableDefinition.name =((Node *)$1)->data.variableDefinition.name;
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
    // Initialize the quadruple list
    stack = (pile *)malloc(sizeof(pile));
    quadList = NULL;
    quadCounter = 0;

    int result = yyparse();

    fclose(file);

    printf("\n");
    printSyntaxTree(&syntaxTree);
    printf("\n");
    printf(">>> Printing the symbols table of the global scope\n");
    printAllScopes(&symbolsTableStack);
    printf("\n");

    printf("Generated Quadruples:\n");
    afficherQuad(quadList);

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
