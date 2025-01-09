#ifndef SEMANTIC_H
#define SEMANTIC_H

#include <stdbool.h>
#include "symbols_table.h"
#include "quadruplets.h"

// Expression structure
typedef struct expression {
    int type;
    char stringValue[255];
    int integerValue;
    double floatValue;
    bool booleanValue;
} expression;

// Variable structure
typedef struct variable {
    symbole *symbole;
} variable;

// Function prototypes
void valeurToString(expression expr, char *valeur);
void generateQuadruplet(char *op, char *arg1, char *arg2, char *result);
void initializeSemanticModule();
void finalizeSemanticModule();

#endif // SEMANTIC_H