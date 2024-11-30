#pragma once

// --- Data Structures ---

typedef struct Attribute
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

typedef struct AttributesList
{
    AttributeNode *first;
    AttributeNode *last;
    int size;
} AttributesList;

typedef struct Symbol
{
    int id;
    char *name;
    AttributesList attributes;
} Symbol;

typedef struct SymbolNode
{
    Symbol symbol;
    struct SymbolNode *next;
    struct SymbolNode *previous;
} SymbolNode;

typedef struct SymbolsTable
{
    SymbolNode *first;
    SymbolNode *last;
    int size;
} SymbolsTable;

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
