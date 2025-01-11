#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#include "quadruplets.h"
#include "symbols_table.h"

#define MAX_QUADRUPLETS 100

extern SymbolsTableStack symbolsTableStack;
Quadruplet quadruplets[MAX_QUADRUPLETS] = {0};
int quadIndex = 0;

static int tempVarCounter = 0;

char* generateTempVar() {
    char *tempVar = malloc(20 * sizeof(char));
    if (tempVar == NULL) {
        fprintf(stderr, "Error: Memory allocation failed in generateTempVar\n");
        exit(EXIT_FAILURE);
    }
    snprintf(tempVar, 20, "t%d", tempVarCounter++);
    return tempVar;
}

void addQuadruple(const char* operateur, const char* operande1, const char* operande2, const char* resultat) 
{
    const char *resolvedOp1 = operande1;
    const char *resolvedOp2 = operande2;
    const char *resolvedResult = resultat;

    if (quadIndex >= MAX_QUADRUPLETS) {
        fprintf(stderr, "Error: Quadruplets array overflow at index %d\n", quadIndex);
        exit(EXIT_FAILURE);
    }

    if (!operateur || !operande1 || !operande2 || !resultat) {
        fprintf(stderr, "Error: NULL argument passed to addQuadruple\n");
        exit(EXIT_FAILURE);
    }

    quadruplets[quadIndex].operateur = malloc(strlen(operateur) + 1);
    if (!quadruplets[quadIndex].operateur) {
        fprintf(stderr, "Error: Memory allocation failed for operateur\n");
        exit(EXIT_FAILURE);
    }
    strcpy(quadruplets[quadIndex].operateur, operateur);

    quadruplets[quadIndex].operande1 = malloc(strlen(operateur) + 1);
    if (!quadruplets[quadIndex].operande1) {
        fprintf(stderr, "Error: Memory allocation failed for operande1\n");
        exit(EXIT_FAILURE);
    }
    strcpy(quadruplets[quadIndex].operande1, resolvedOp1);

    quadruplets[quadIndex].operande2 = malloc(strlen(operateur) + 1);
    if (!quadruplets[quadIndex].operande2) {
        fprintf(stderr, "Error: Memory allocation failed for operande2\n");
        exit(EXIT_FAILURE);
    }
    strcpy(quadruplets[quadIndex].operande2, resolvedOp2);

    quadruplets[quadIndex].resultat = malloc(strlen(operateur) + 1);
    if (!quadruplets[quadIndex].resultat) {
        fprintf(stderr, "Error: Memory allocation failed for resultat\n");
        exit(EXIT_FAILURE);
    }
    strcpy(quadruplets[quadIndex].resultat, resolvedResult);

    quadIndex++;
}

void checkTypeCompatibility(const char* op1, const char* op2) {
    // Symbol* symbol1 = searchSymbolInAllScopes(&symbolsTableStack, op1);
    // Symbol* symbol2 = searchSymbolInAllScopes(&symbolsTableStack, op2);

    if (!op1 || !op2) {
        fprintf(stderr, "Error: One or both operands are undefined (%s, %s)\n", op1, op2);
        exit(EXIT_FAILURE);
    }

    if (strcmp(op1, op2) != 0) {
        fprintf(stderr, "Error: Type mismatch between (%s) and (%s)\n",
                op1, op2);
        exit(EXIT_FAILURE);
    }
}


void afficherQuadruplets() {
    printf("\nQuadruplets générés:\n");
    printf("Op\tOp1\tOp2\tRes\n");
    for (int i = 0; i < quadIndex; i++) {
        printf("%s\t%s\t%s\t%s\n", quadruplets[i].operateur, quadruplets[i].operande1, quadruplets[i].operande2, quadruplets[i].resultat);
    }
}

void freeQuadruplets() {
    for (int i = 0; i < quadIndex; i++) {
        free(quadruplets[i].operateur);
        free(quadruplets[i].operande1);
        free(quadruplets[i].operande2);
        free(quadruplets[i].resultat);
    }
}