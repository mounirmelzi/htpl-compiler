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

#define MAX_TERMINALS 20
#define MAX_NON_TERMINALS 10

int yyerror(const char *);


extern int column_counter;

char *filename;
SymbolsTable symbolsTable;




// Function declaration for handling Début and Suivant sets
void initializeSets(int index, char *symbol, char **debut, int debut_size, char **suivant, int suivant_size);

// Structure for storing Début and Suivant sets for each non-terminal
typedef struct {
    char *symbol;
    char **debut_set;
    int debut_size;
    char **suivant_set;
    int suivant_size;
} NonTerminalSets;

NonTerminalSets sets[3]; 

// Sample data for Début and Suivant sets
char* debut_calculation[] = {"INTEGER_LITERAL","FLOAT_LITERAL","IDENTIFIER", "FUNCTION_NAME", "LEFT_PARENTHESIS", "MINUS"};
int debut_calculation_size = 6;

char* suivant_calculation[] = {"EQUAL", "NOT_EQUAL", "LESS", "LESS_OR_EQUAL", "GREATER", "GREATER_OR_EQUAL", "RIGHT_PARENTHESIS", "SEMICOLON", "COMMA"};
int suivant_calculation_size = 9;

char* debut_calculation_tail[] = {"PLUS", "MINUS", "MULTIPLY", "DIVIDE", "MODULO", "ε"};
int debut_calculation_tail_size = 6;

char* suivant_calculation_tail[] = {"EQUAL", "NOT_EQUAL", "LESS", "LESS_OR_EQUAL", "GREATER", "GREATER_OR_EQUAL", "RIGHT_PARENTHESIS", "SEMICOLON", "COMMA"};
int suivant_calculation_tail_size = 9;

char* debut_primary[] = {"INTEGER_LITERAL","FLOAT_LITERAL", "IDENTIFIER", "FUNCTION_NAME", "LEFT_PARENTHESIS", "MINUS"};
int debut_primary_size = 6;

char* suivant_primary[] = {"PLUS", "MINUS", "MULTIPLY", "DIVIDE", "MODULO", "EQUAL", "NOT_EQUAL", "LESS", "LESS_OR_EQUAL", "GREATER", "GREATER_OR_EQUAL", "RIGHT_PARENTHESIS", "SEMICOLON", "COMMA"};
int suivant_primary_size = 14;

// Initialize the sets for the non-terminals
void initializeSets(int index, char *symbol, char **debut, int debut_size, char **suivant, int suivant_size) {
    sets[index].symbol = symbol;
    sets[index].debut_set = debut;
    sets[index].debut_size = debut_size;
    sets[index].suivant_set = suivant;
    sets[index].suivant_size = suivant_size;
}


char* non_terminals[] = { "calculation","calculation_tail", "primary"};
int non_terminal_count = sizeof(non_terminals) / sizeof(non_terminals[0]);

char* terminals[] = {"INTEGER_LITERAL","FLOAT_LITERAL","IDENTIFIER", "FUNCTION_NAME",  "PLUS", "MINUS", "MULTIPLY", "DIVIDE", "MODULO", "EQUAL", "NOT_EQUAL", "LESS", "LESS_OR_EQUAL", "GREATER", "GREATER_OR_EQUAL", "RIGHT_PARENTHESIS", "SEMICOLON", "COMMA","LEFT_PARENTHESIS"};
int terminal_count = sizeof(terminals) / sizeof(terminals[0]);

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
%nonassoc EQUAL NOT_EQUAL
%nonassoc LESS LESS_OR_EQUAL GREATER GREATER_OR_EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%right NEG
%right NOT



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
    : IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS GREATER statement_list IF_END
    | IF_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS GREATER statement_list ELSE statement_list IF_END
;

while_statement
    : WHILE_BEGIN LEFT_PARENTHESIS condition RIGHT_PARENTHESIS GREATER statement_list WHILE_END
;


/* expression rules */

condition
    : calculation EQUAL calculation
    | calculation NOT_EQUAL calculation
    | calculation LESS calculation
    | calculation LESS_OR_EQUAL calculation
    | calculation GREATER calculation
    | calculation GREATER_OR_EQUAL calculation
    | LEFT_PARENTHESIS condition RIGHT_PARENTHESIS
    | condition AND condition
    | condition OR condition
    | NOT condition
;
/* ********************************   */
/*
calculation
    : literal
    | variable
    | function_call
    | LEFT_PARENTHESIS calculation RIGHT_PARENTHESIS
    | calculation PLUS calculation
    | calculation MINUS calculation
    | calculation MULTIPLY calculation
    | calculation DIVIDE calculation
    | calculation MODULO calculation
    | MINUS calculation %prec NEG
;
*/
/* ********************************   */

calculation
    : primary calculation_tail
;

calculation_tail
    : PLUS primary calculation_tail
    | MINUS primary calculation_tail
    | MULTIPLY primary calculation_tail
    | DIVIDE primary calculation_tail
    | MODULO primary calculation_tail
    | %empty
;

primary
    : literal
    | variable
    | function_call
    | LEFT_PARENTHESIS calculation RIGHT_PARENTHESIS
    | MINUS primary %prec NEG
;

expression
    : calculation
    | condition
;

%%



/* *** *** section de code *** *** */

int yyerror(const char *error_message) {
    printf("File \"%s\", line %d, character %d: %s\n", filename, yylineno, column_counter, error_message);
}


char *LL1_table[MAX_NON_TERMINALS][MAX_TERMINALS];

bool isTerminal(const char *symbol) {
    for (int i = 0; i < terminal_count; i++) {
        if (strcmp(symbol, terminals[i]) == 0) {
            return true;
        }
    }
    return false;
}

// Function to print the LL(1) table
void printLL1Table() {
    printf("LL(1) Table:\n");
    for (int i = 0; i < non_terminal_count; i++) {
        for (int j = 0; j < terminal_count; j++) {
            if (LL1_table[i][j] != NULL) {
                printf("%s (%s) -> %s\n", sets[i].symbol, terminals[j], LL1_table[i][j]);
            }
        }
    }
}


// Add production to the LL(1) table
void addProductionToLL1Table(int non_terminal_index, int terminal_index, const char *production) {
    if (LL1_table[non_terminal_index][terminal_index] == NULL) {
        LL1_table[non_terminal_index][terminal_index] = strdup(production);
    } else {
        // Conflict: If a production already exists, handle the conflict (error or other actions)
        printf("Conflict detected for non-terminal %s with terminal %s\n", sets[non_terminal_index].symbol, terminals[terminal_index]);
        
    }
}

void buildLL1Table() {
    for (int i = 0; i < 3; i++) {
        NonTerminalSets *nt_set = &sets[i];

        // Iterate through the production rules for the non-terminal
        for (int j = 0; j < nt_set->debut_size; j++) {
            const char *first_symbol = nt_set->debut_set[j];

            // If first_symbol is a terminal, add the production to the LL1 table
            if (isTerminal(first_symbol)) {
                for (int k = 0; k < terminal_count; k++) {
                    if (strcmp(first_symbol, terminals[k]) == 0) {
                        char production[100];
                        snprintf(production, sizeof(production), "%s -> %s", nt_set->symbol, first_symbol);
                        addProductionToLL1Table(i, k, production);
                    }
                }
            } else {
                // Handle non-terminal as a first symbol and look up its debut set
                for (int k = 0; k < nt_set->debut_size; k++) {
                    const char *next_symbol = nt_set->debut_set[k];
                    if (!isTerminal(next_symbol)) {
                        // Process for follow (ε case)
                        for (int l = 0; l < nt_set->suivant_size; l++) {
                            const char *follow_symbol = nt_set->suivant_set[l];
                            for (int m = 0; m < terminal_count; m++) {
                                if (strcmp(follow_symbol, terminals[m]) == 0) {
                                    char production[100];
                                    snprintf(production, sizeof(production), "%s -> ε", nt_set->symbol);
                                    addProductionToLL1Table(i, m, production);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
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

    initializeSets(0, "calculation", debut_calculation, debut_calculation_size, suivant_calculation, suivant_calculation_size);
    initializeSets(1, "calculation_tail", debut_calculation_tail, debut_calculation_tail_size, suivant_calculation_tail, suivant_calculation_tail_size);
    initializeSets(2, "primary", debut_primary, debut_primary_size, suivant_primary, suivant_primary_size);

    initializeSymbolsTable(&symbolsTable);

    int result = yyparse();

    fclose(file);
    printf("\n");

        for (int i = 0; i < 3; i++) {
        printf("Non-terminal: %s\n", sets[i].symbol);
        
        // Print Début set
        printf("  Début set: ");
        for (int j = 0; j < sets[i].debut_size; j++) {
            printf("%s ", sets[i].debut_set[j]);
        }
        printf("\n");

        // Print Suivant set
        printf("  Suivant set: ");
        for (int j = 0; j < sets[i].suivant_size; j++) {
            printf("%s ", sets[i].suivant_set[j]);
        }
        printf("\n\n");
    }


    buildLL1Table();
    printLL1Table();

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
