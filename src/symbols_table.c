#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "symbols_table.h"

void initializeSymbolsTable(SymbolsTable *table) // initialise une table des symboles vide
{
    table->first = NULL;
    table->last = NULL;
    table->size = 0;
}

void deleteSymbolsTable(SymbolsTable *table) //
{
    SymbolNode *current = table->first;
    while (current)
    {
        SymbolNode *toDelete = current;
        current = current->next;

        free(toDelete->symbol.name); // Free the symbol name
        free(toDelete);
    }

    table->first = NULL;
    table->last = NULL;
    table->size = 0;
}

Symbol *searchSymbol(SymbolsTable *table, const char *name) // parcours la table des symboles pour trouver un symbole dont le nom correspond a name
{
    SymbolNode *current = table->first;
    while (current)
    {
        if (strcmp(current->symbol.name, name) == 0)
            return &current->symbol;
        current = current->next;
    }

    return NULL;
}

Symbol *createSymbol(SymbolsTable *table, const char *name) // ajoute un nouveau sumbole a la table si il n'existe pas deja
{
    Symbol *symbol;
    if ((symbol = searchSymbol(table, name)))
        return symbol; // Symbol already exists

    // allouer espace memoire
    SymbolNode *newNode = (SymbolNode *)malloc(sizeof(SymbolNode));

    newNode->symbol.name = strdup(name);

    // ajout du nouveau symbole a la fin
    newNode->next = NULL;
    newNode->previous = table->last;

    if (table->last)
        table->last->next = newNode;
    else
        table->first = newNode;

    table->last = newNode;
    table->size++;           // mise a jour de la taille
    return &newNode->symbol; // Success
}

bool deleteSymbol(SymbolsTable *table, const char *name) // supprimer un symbole et ses attributs de la table en ajustant les liens de la liste doublement chainee
{
    SymbolNode *current = table->first;
    while (current)
    {
        if (strcmp(current->symbol.name, name) == 0)
        {
            if (current->previous)
                current->previous->next = current->next;
            else
                table->first = current->next;

            if (current->next)
                current->next->previous = current->previous;
            else
                table->last = current->previous;

            free(current->symbol.name); // Free symbol name
            free(current);
            table->size--;
            return true; // Success
        }
        current = current->next;
    }

    return false; // Symbol not found
}

void printSymbolsTable(const SymbolsTable *table) // parcourt et affiche tous les symboles dans la table, ainsi que leurs attributs
{
    if (!table || table->size == 0)
    {
        printf("Symbols Table is empty.\n");
        return;
    }

    printf("Symbols Table (%d symbols):\n", table->size);

    SymbolNode *current = table->first;
    while (current != NULL)
    {
        printf("- Symbol: %s\n", current->symbol.name);
        current = current->next;
    }
}

void initializeSymbolsTableStack(SymbolsTableStack *stack)
{
    stack->first = NULL;
    stack->last = NULL;
    stack->size = 0;
}

void deleteSymbolsTableStack(SymbolsTableStack *stack)
{
    SymbolsTableStackNode *current = stack->first;
    while (current != NULL)
    {
        SymbolsTableStackNode *next = current->next;
        deleteSymbolsTable(&(current->table));
        free(current);
        current = next;
    }

    initializeSymbolsTableStack(stack);
}

void pushScope(SymbolsTableStack *stack)
{
    SymbolsTableStackNode *newNode = (SymbolsTableStackNode *)malloc(sizeof(SymbolsTableStackNode));

    initializeSymbolsTable(&(newNode->table));
    newNode->next = NULL;
    newNode->previous = NULL;

    if (stack->first == NULL)
    {
        stack->first = newNode;
        stack->last = newNode;
    }
    else
    {
        newNode->previous = stack->last;
        stack->last->next = newNode;
        stack->last = newNode;
    }

    stack->size++;
}

SymbolsTable *popScope(SymbolsTableStack *stack)
{
    if (stack->last == NULL)
    {
        fprintf(stderr, "Cannot pop from empty stack\n");
        return NULL;
    }

    SymbolsTableStackNode *nodeToRemove = stack->last;

    if (stack->first == stack->last)
    {
        stack->first = NULL;
        stack->last = NULL;
    }
    else
    {
        stack->last = nodeToRemove->previous;
        stack->last->next = NULL;
    }

    stack->size--;

    SymbolsTable *table = (SymbolsTable *)malloc(sizeof(SymbolsTable));
    table->first = nodeToRemove->table.first;
    table->last = nodeToRemove->table.last;
    table->size = nodeToRemove->table.size;

    free(nodeToRemove);

    return table;
}

SymbolsTable *getCurrentScope(SymbolsTableStack *stack)
{
    if (stack->last == NULL)
        return NULL;

    return &(stack->last->table);
}

Symbol *searchSymbolInAllScopes(SymbolsTableStack *stack, const char *name)
{
    if (stack->last == NULL)
        return NULL;

    SymbolsTableStackNode *current = stack->last;
    while (current != NULL)
    {
        Symbol *symbol = searchSymbol(&(current->table), name);
        if (symbol != NULL)
            return symbol;

        current = current->previous;
    }

    return NULL;
}

Symbol *searchSymbolInCurrentScope(SymbolsTableStack *stack, const char *name)
{
    SymbolsTable *currentScope = getCurrentScope(stack);
    if (currentScope == NULL)
        return NULL;

    return searchSymbol(currentScope, name);
}

void printAllScopes(const SymbolsTableStack *stack)
{
    if (stack->first == NULL)
    {
        printf("Symbols Table Stack is empty\n");
        return;
    }

    printf("Total number of scopes: %d\n", stack->size);

    SymbolsTableStackNode *current = stack->first;
    int scopeNum = 0;
    while (current != NULL)
    {
        printf("=== Scope %d ===\n", scopeNum++);
        printSymbolsTable(&(current->table));
        current = current->next;
    }
}
