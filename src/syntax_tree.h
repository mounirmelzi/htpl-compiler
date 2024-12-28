#pragma once

// --- Data Structures ---

typedef struct Node
{
    char *name;
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
int addChildren(Node *parent, int size, ...);
Node *findNode(SyntaxTree *tree, const char *name);
void printSyntaxTree(const SyntaxTree *tree);
