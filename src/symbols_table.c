#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbols_table.h"

void initializeSymbolsTable(SymbolsTable *table)
{
    table->first = NULL;
    table->last = NULL;
    table->size = 0;
}

void deleteSymbolsTable(SymbolsTable *table)
{
    SymbolNode *current = table->first;
    while (current)
    {
        SymbolNode *toDelete = current;
        current = current->next;

        // Free attributes list
        while (toDelete->symbol.attributes.first)
        {
            deleteAttribute(&toDelete->symbol.attributes, toDelete->symbol.attributes.first->attribute.name);
        }

        free(toDelete->symbol.name); // Free the symbol name
        free(toDelete);
    }

    table->first = NULL;
    table->last = NULL;
    table->size = 0;
}

Symbol *searchSymbol(SymbolsTable *table, const char *name)
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

Symbol *createSymbol(SymbolsTable *table, int id, const char *name)
{
    Symbol *symbol;
    if ((symbol = searchSymbol(table, name)))
        return symbol; // Symbol already exists

    SymbolNode *newNode = malloc(sizeof(SymbolNode));
    if (!newNode)
        return NULL;

    newNode->symbol.id = id;
    newNode->symbol.name = strdup(name);
    initializeAttributesList(&newNode->symbol.attributes); // Initialize empty attributes list

    newNode->next = NULL;
    newNode->previous = table->last;

    if (table->last)
        table->last->next = newNode;
    else
        table->first = newNode;

    table->last = newNode;
    table->size++;
    return &newNode->symbol; // Success
}

int deleteSymbol(SymbolsTable *table, const char *name)
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

            // Free the attributes
            while (current->symbol.attributes.first)
            {
                deleteAttribute(&current->symbol.attributes, current->symbol.attributes.first->attribute.name);
            }

            free(current->symbol.name); // Free symbol name
            free(current);
            table->size--;
            return 1; // Success
        }
        current = current->next;
    }
    return 0; // Symbol not found
}

Attribute *searchAttribute(AttributesList *attributes, const char *name)
{
    AttributeNode *current = attributes->first;
    while (current)
    {
        if (strcmp(current->attribute.name, name) == 0)
            return &current->attribute;
        current = current->next;
    }
    return NULL;
}

Attribute *createAttribute(AttributesList *attributes, const char *name, const char *value)
{
    Attribute *attribute;
    if ((attribute = searchAttribute(attributes, name)))
        return attribute; // Attribute already exists

    AttributeNode *newNode = malloc(sizeof(AttributeNode));
    if (!newNode)
        return NULL;

    newNode->attribute.name = strdup(name);
    newNode->attribute.value = strdup(value);
    newNode->next = NULL;
    newNode->previous = attributes->last;

    if (attributes->last)
        attributes->last->next = newNode;
    else
        attributes->first = newNode;

    attributes->last = newNode;
    attributes->size++;
    return &newNode->attribute; // Success
}

int deleteAttribute(AttributesList *attributes, const char *name)
{
    AttributeNode *current = attributes->first;
    while (current)
    {
        if (strcmp(current->attribute.name, name) == 0)
        {
            if (current->previous)
                current->previous->next = current->next;
            else
                attributes->first = current->next;

            if (current->next)
                current->next->previous = current->previous;
            else
                attributes->last = current->previous;

            free(current->attribute.name);  // Free attribute name
            free(current->attribute.value); // Free attribute value
            free(current);
            attributes->size--;
            return 1; // Success
        }
        current = current->next;
    }
    return 0; // Attribute not found
}

int updateAttribute(AttributesList *attributes, const char *name, const char *newValue)
{
    Attribute *attribute = searchAttribute(attributes, name);
    if (!attribute)
        return 0; // Attribute not found

    free(attribute->value);
    attribute->value = strdup(newValue);
    return 1; // Success
}

void initializeAttributesList(AttributesList *attributes)
{
    attributes->first = NULL;
    attributes->last = NULL;
    attributes->size = 0;
}

void printAttributesList(const AttributesList *attributes)
{
    if (!attributes || attributes->size == 0)
    {
        printf("  No attributes.\n");
        return;
    }

    printf("  Attributes (%d):\n", attributes->size);

    AttributeNode *current = attributes->first;
    while (current != NULL)
    {
        printf("    - %s: %s\n", current->attribute.name, current->attribute.value);
        current = current->next;
    }
}

void printSymbolsTable(const SymbolsTable *table)
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
        printf("- Symbol ID: %d, Name: %s\n", current->symbol.id, current->symbol.name);
        printAttributesList(&(current->symbol.attributes));
        current = current->next;
    }
}
