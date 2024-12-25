#include "tree.h"

Node *createNode(char *name, int childCount, ...) {
    Node *node = malloc(sizeof(Node));
    node->name = strdup(name);
    node->childCount = childCount;
    node->children = malloc(sizeof(Node *) * childCount);

    va_list args;
    va_start(args, childCount);
    for (int i = 0; i < childCount; i++) {
        node->children[i] = va_arg(args, Node *);
    }
    va_end(args);

    return node;
}

void printTree(Node *node, int depth) {
    for (int i = 0; i < depth; i++) printf("  ");
    printf("%s\n", node->name);
    for (int i = 0; i < node->childCount; i++) {
        printTree(node->children[i], depth + 1);
    }
}
