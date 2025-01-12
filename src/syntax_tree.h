#pragma once

#include <stdbool.h>

#include "global.h"

// --- Data Structures ---

typedef union Data
{
    VariableDefinition variableDefinition;
} Data;

typedef struct Node
{
    char *name;
    char* type; 
    Data data;
    struct Node *parent;
    struct Node **children;
    int size;
    int capacity;
} Node;

typedef struct SyntaxTree
{
    Node *root;
    int size;
} SyntaxTree;

// --- Functions ---

void initializeSyntaxTree(SyntaxTree *tree);
void deleteSyntaxTree(SyntaxTree *tree);

Node *createNode(SyntaxTree *tree, const char *name);
bool addChildren(Node *parent, int size, ...);
Node *findNode(SyntaxTree *tree, const char *name);
void printSyntaxTree(const SyntaxTree *tree);
