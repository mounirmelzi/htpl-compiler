#include "semantic.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Global variables
quad *quadList = NULL;  // List of quadruples
int quadCounter = 1;    // Quadruple counter

// Initialize the semantic module
void initializeSemanticModule() {
    quadList = NULL;
    quadCounter = 1;
}

// Finalize the semantic module
void finalizeSemanticModule() {
    afficherQuad(quadList);  // Print the generated quadruples
    // Free memory if needed
}

// Convert expression value to string
void valeurToString(expression expr, char *valeur) {
    switch (expr.type) {
        case TYPE_INTEGER:
            sprintf(valeur, "%d", expr.integerValue);
            break;
        case TYPE_FLOAT:
            sprintf(valeur, "%.4f", expr.floatValue);
            break;
        case TYPE_STRING:
            sprintf(valeur, "%s", expr.stringValue);
            break;
        case TYPE_BOOLEAN:
            sprintf(valeur, "%s", expr.booleanValue ? "true" : "false");
            break;
        default:
            strcpy(valeur, "");
            break;
    }
}

// Generate a quadruple
void generateQuadruplet(char *op, char *arg1, char *arg2, char *result) {
    insererQuadreplet(&quadList, op, arg1, arg2, result, quadCounter++);
}