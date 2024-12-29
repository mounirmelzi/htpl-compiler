#pragma once

// --- Data Structures ---

typedef struct Attribute // represente un attribut d'un symbole (categorie, type, ...)
{
    char *name;
    char *value;
} Attribute;

typedef struct AttributeNode
{
    Attribute attribute;
    struct AttributeNode *next;
    struct AttributeNode *previous;
} AttributeNode;

typedef struct AttributesList // liste doublement chainee contenant des AttributeNode
{
    AttributeNode *first; // premier noeud
    AttributeNode *last;  // dernier noeud
    int size;             // nbr total d'attributs
} AttributesList;

typedef struct Symbol // represente une entite identifiable dans le programme (variable, function, struct,..)
{
    int id;
    char *name;
    AttributesList attributes; // liste des attributs associes au symbole
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
Symbol *createSymbol(SymbolsTable *table, int id, const char *name);
int deleteSymbol(SymbolsTable *table, const char *name);

Attribute *searchAttribute(AttributesList *attributes, const char *name);
Attribute *createAttribute(AttributesList *attributes, const char *name, const char *value);
int deleteAttribute(AttributesList *attributes, const char *name);
int updateAttribute(AttributesList *attributes, const char *name, const char *newValue);
void initializeAttributesList(AttributesList *attributes);

void printAttributesList(const AttributesList *attributes);
void printSymbolsTable(const SymbolsTable *table);

void initializeSymbolsTableStack(SymbolsTableStack *stack);
void deleteSymbolsTableStack(SymbolsTableStack *stack);

void pushScope(SymbolsTableStack *stack);
SymbolsTable *popScope(SymbolsTableStack *stack);
SymbolsTable *getCurrentScope(SymbolsTableStack *stack);

Symbol *searchSymbolInAllScopes(SymbolsTableStack *stack, const char *name);
Symbol *searchSymbolInCurrentScope(SymbolsTableStack *stack, const char *name);

void printAllScopes(const SymbolsTableStack *stack);
