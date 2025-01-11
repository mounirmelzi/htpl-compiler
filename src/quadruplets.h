#pragma once

#include <stdbool.h>

#include "global.h"

typedef struct {
    char* operateur;
    char* operande1;
    char* operande2;
    char* resultat;
} Quadruplet;

char* generateTempVar(); 
void addQuadruple(const char* operateur, const char* operande1, const char* operande2, const char* resultat);
void checkTypeCompatibility(const char* op1, const char* op2);
void afficherQuadruplets();
void freeQuadruplets();