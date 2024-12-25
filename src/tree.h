#pragma once

#ifndef TREE_H
#define TREE_H

#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct Node {
    char *name;
    struct Node **children;
    int childCount;
} Node;

Node *createNode(char *name, int childCount, ...);
void printTree(Node *node, int depth);

#endif 
