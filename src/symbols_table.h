#pragma once

#include <stdbool.h>

// --- Data Structures ---

typedef struct VariableDefinition
{
    char *name;
    char *type;
} VariableDefinition;

typedef struct VariableValue
{
    bool is_initialized;
} VariableValue;

typedef struct FunctionValue
{
    VariableDefinition *params;
    int params_size;
} FunctionValue;

typedef struct StructValue
{
    VariableDefinition *fields;
    int fields_size;
} StructValue;

typedef union SymbolValue
{
    VariableValue variableValue;
    FunctionValue functionValue;
    StructValue structValue;
} SymbolValue;

typedef enum SymbolCategory
{
    VARIABLE,
    FUNCTION,
    STRUCT,
} SymbolCategory;

typedef struct Symbol // represente une entite identifiable dans le programme (variable, function, struct,..)
{
    char *name;
    char *type;
    SymbolCategory category;
    SymbolValue value;
} Symbol;

typedef struct SymbolNode
{
    Symbol symbol;
    struct SymbolNode *next;
    struct SymbolNode *previous;
} SymbolNode;

typedef struct SymbolsTable // liste doublement chainee contenant des SymbolNode
{
    SymbolNode *first; // premier noeud
    SymbolNode *last;  // dernier noeud
    int size;          // nbr total de symboles
} SymbolsTable;

typedef struct SymbolsTableStackNode
{
    SymbolsTable table;
    struct SymbolsTableStackNode *next;
    struct SymbolsTableStackNode *previous;
} SymbolsTableStackNode;

typedef struct SymbolsTableStack
{
    SymbolsTableStackNode *first;
    SymbolsTableStackNode *last;
    int size;
} SymbolsTableStack;

// --- Functions ---

void initializeSymbolsTable(SymbolsTable *table);
void deleteSymbolsTable(SymbolsTable *table);

Symbol *searchSymbol(SymbolsTable *table, const char *name);
Symbol *createSymbol(SymbolsTable *table, const char *name, const char *type, SymbolCategory category, SymbolValue value);
bool deleteSymbol(SymbolsTable *table, const char *name);

void printSymbolsTable(const SymbolsTable *table);

void initializeSymbolsTableStack(SymbolsTableStack *stack);
void deleteSymbolsTableStack(SymbolsTableStack *stack);

void pushScope(SymbolsTableStack *stack);
SymbolsTable *popScope(SymbolsTableStack *stack);
SymbolsTable *getCurrentScope(SymbolsTableStack *stack);

Symbol *searchSymbolInAllScopes(SymbolsTableStack *stack, const char *name);
Symbol *searchSymbolInCurrentScope(SymbolsTableStack *stack, const char *name);

void printAllScopes(const SymbolsTableStack *stack);
