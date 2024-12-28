#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "syntax_tree.h"

void initializeSyntaxTree(SyntaxTree *tree)
{
    tree->root = NULL;
    tree->size = 0;
}

Node *createNode(SyntaxTree *tree, const char *name)
{
    Node *node = malloc(sizeof(Node));
    if (!node)
        return NULL;

    node->name = strdup(name);
    if (!node->name)
    {
        free(node);
        return NULL;
    }

    node->parent = NULL;
    node->capacity = 4;
    node->size = 0;
    node->children = malloc(sizeof(Node *) * node->capacity);

    if (!node->children)
    {
        free(node->name);
        free(node);
        return NULL;
    }

    tree->size++;
    return node;
}

int addChildren(Node *parent, int size, ...)
{
    if (!parent || size <= 0)
        return 0;

    if (parent->size + size > parent->capacity)
    {
        Node **new_children = realloc(parent->children, sizeof(Node *) * (parent->size + size));
        if (!new_children)
            return 0;
        parent->children = new_children;
        parent->capacity = parent->size + size;
    }

    va_list args;
    va_start(args, size);
    for (int i = 0; i < size; i++)
    {
        Node *child = va_arg(args, Node *);

        if (!child)
            continue;

        parent->children[parent->size++] = child;
        child->parent = parent;
    }
    va_end(args);

    return 1;
}

Node *findNode(SyntaxTree *tree, const char *name)
{
    if (!tree->root)
        return NULL;

    Node **stack = malloc(sizeof(Node *) * tree->size);
    int top = 0;
    stack[top++] = tree->root;

    while (top > 0)
    {
        Node *current = stack[--top];
        if (strcmp(current->name, name) == 0)
        {
            free(stack);
            return current;
        }

        for (int i = 0; i < current->size; i++)
        {
            stack[top++] = current->children[i];
        }
    }

    free(stack);
    return NULL;
}

static void deleteNode(Node *node)
{
    if (!node)
        return;

    for (int i = 0; i < node->size; i++)
    {
        deleteNode(node->children[i]);
    }

    free(node->children);
    free(node->name);
    free(node);
}

void deleteSyntaxTree(SyntaxTree *tree)
{
    if (tree->root)
    {
        deleteNode(tree->root);
    }
    initializeSyntaxTree(tree);
}

static void printNodeRecursive(const Node *node, int depth)
{
    for (int i = 0; i < depth; i++)
        printf("  ");
    printf("%d - %s\n", depth, node->name);

    for (int i = 0; i < node->size; i++)
    {
        printNodeRecursive(node->children[i], depth + 1);
    }
}

void printSyntaxTree(const SyntaxTree *tree)
{
    if (!tree || tree->size == 0)
    {
        printf("Syntax Tree is empty.\n");
        return;
    }

    printf("Syntax Tree (%d nodes):\n", tree->size);

    if (tree->root)
    {
        printNodeRecursive(tree->root, 0);
    }
}
