/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "tokens.h"
#include "symbols_table.h"


char *filename; // the file to compile
int column_counter = 1;  // custom column counter

SymbolsTable symbolsTable; // global variable for the symbols table

%}



/* *** *** section des macros *** *** */

DIGIT       [0-9]
ID          [a-zA-Z][a-zA-Z0-9]*



/* *** *** section des actions *** *** */

%%

 /* Mots-clés */
"let"               { printf("TOKEN: LET (ligne: %d)\n", yylineno); column_counter += yyleng; return LET; }
"return"            { printf("TOKEN: RETURN (ligne: %d)\n", yylineno); column_counter += yyleng; return RETURN; }
"write"             { printf("TOKEN: WRITE (ligne: %d)\n", yylineno); column_counter += yyleng; return WRITE; }
"read"              { printf("TOKEN: READ (ligne: %d)\n", yylineno); column_counter += yyleng; return READ; }

 /* Fonctions */
"<function"         { printf("TOKEN: FUNCTION_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return FUNCTION_BEGIN; }
"</function>"       { printf("TOKEN: FUNCTION_END (ligne: %d)\n", yylineno); column_counter += yyleng; return FUNCTION_END; }
"main" {
    printf("TOKEN: MAIN (ligne: %d)\n", yylineno);
    column_counter += yyleng;

    Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, yytext);
    createAttribute(&symbol->attributes, "category", "function");
    createAttribute(&symbol->attributes, "entry", "true");

    return MAIN;
}

_[0-9]*{ID} {
    printf("TOKEN: FUNCTION_NAME(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;

    Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, yytext);
    createAttribute(&symbol->attributes, "category", "function");

    return FUNCTION_NAME;
}

 /* Boucles et conditions */
"<if"               { printf("TOKEN: IF_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return IF_BEGIN; }
"</if>"             { printf("TOKEN: IF_END (ligne: %d)\n", yylineno); column_counter += yyleng; return IF_END; }
"<else>"            { printf("TOKEN: ELSE (ligne: %d)\n", yylineno); column_counter += yyleng; return ELSE; }
"<while"            { printf("TOKEN: WHILE_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return WHILE_BEGIN; }
"</while>"          { printf("TOKEN: WHILE_END (ligne: %d)\n", yylineno); column_counter += yyleng; return WHILE_END; }

 /* Types */
"int"               { printf("TOKEN: TYPE_INT (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_INT; }
"float"             { printf("TOKEN: TYPE_FLOAT (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_FLOAT; }
"string"            { printf("TOKEN: TYPE_STRING (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_STRING; }
"boolean"           { printf("TOKEN: TYPE_BOOLEAN (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_BOOLEAN; }
"char"              { printf("TOKEN: TYPE_CHAR (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_CHAR; }
"void"              { printf("TOKEN: TYPE_VOID (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_VOID; }

 /* Littéraux */
{DIGIT}+            { printf("TOKEN: INTEGER_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); column_counter += yyleng; return INTEGER_LITERAL; }
{DIGIT}+"."{DIGIT}+ { printf("TOKEN: FLOAT_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); column_counter += yyleng; return FLOAT_LITERAL; }

 /* traietement d'une chaine de caractere */
\"([^\"\\]|\\["\\nt])*\" {
    // si un caractere special est precédé par un antislash, le caractere sera concidéré comme faisant partie de la chaine.
    char processed[1024]; //contenu final de la chaine
    int i = 0, j = 0;

    while (yytext[i] != '\0') {
        if (yytext[i] == '\\') {
            i++;
            switch (yytext[i]) {
                case 'n':  processed[j++] = '\n'; break; // nouvelle ligne
                case 'r':  processed[j++] = '\r'; break; // retour chariot
                case 't':  processed[j++] = '\t'; break; // tabulation
                case '\\': processed[j++] = '\\'; break; // antislash
                case '"':  processed[j++] = '"';  break; // guillemets doubles
                case '\'': processed[j++] = '\''; break; // apostrophe
                default:
                    // Si un caractère invalide suit un antislash.
                    printf(stderr, "Warning: Unknown escape sequence '\\%c' at line %d\n", yytext[i], yylineno);
                    processed[j++] = yytext[i];
            } 
        } else if (yytext[i] != '"') {
            // ajouter les caracteres normaux, sauf les guillemets d'encadrement.
            processed[j++] = yytext[i];
        }
        i++;
    }
    processed[j] = '\0'; // terminaison de la chaîne
    printf("TOKEN: STRING_LITERAL(%s) (ligne: %d)\n", processed, yylineno);
    column_counter += yyleng;
    return STRING_LITERAL;
}

"true"|"false"      { printf("TOKEN: BOOLEAN_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); column_counter += yyleng; return BOOLEAN_LITERAL; }
'.'                 { printf("TOKEN: CHAR_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); column_counter += yyleng; return CHAR_LITERAL; }

 /* Tableaux */
"["                 { printf("TOKEN: LEFT_BRACKET (ligne: %d)\n", yylineno); column_counter += yyleng; return LEFT_BRACKET; }
"]"                 { printf("TOKEN: RIGHT_BRACKET (ligne: %d)\n", yylineno); column_counter += yyleng; return RIGHT_BRACKET; }

 /* Enregistrements (Struct) */
"<struct"           { printf("TOKEN: STRUCT_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return STRUCT_BEGIN; }
"</struct>"         { printf("TOKEN: STRUCT_END (ligne: %d)\n", yylineno); column_counter += yyleng; return STRUCT_END; }

 /* Opérateurs */
"+"                 { printf("TOKEN: PLUS (ligne: %d)\n", yylineno); column_counter += yyleng; return PLUS; }
"-"                 { printf("TOKEN: MINUS (ligne: %d)\n", yylineno); column_counter += yyleng; return MINUS; }
"*"                 { printf("TOKEN: MULTIPLY (ligne: %d)\n", yylineno); column_counter += yyleng; return MULTIPLY; }
"/"                 { printf("TOKEN: DIVIDE (ligne: %d)\n", yylineno); column_counter += yyleng; return DIVIDE; }
"%"                 { printf("TOKEN: MODULO (ligne: %d)\n", yylineno); column_counter += yyleng; return MODULO; }
"="                 { printf("TOKEN: ASSIGN (ligne: %d)\n", yylineno); column_counter += yyleng; return ASSIGN; }
"=="                { printf("TOKEN: EQUAL (ligne: %d)\n", yylineno); column_counter += yyleng; return EQUAL; }
"!="                { printf("TOKEN: NOT_EQUAL (ligne: %d)\n", yylineno); column_counter += yyleng; return NOT_EQUAL; }
"<"                 { printf("TOKEN: LESS (ligne: %d)\n", yylineno); column_counter += yyleng; return LESS; }
"<="                { printf("TOKEN: LESS_OR_EQUAL (ligne: %d)\n", yylineno); column_counter += yyleng; return LESS_OR_EQUAL; }
">"                 { printf("TOKEN: GREATER (ligne: %d)\n", yylineno); column_counter += yyleng; return GREATER; }
">="                { printf("TOKEN: GREATER_OR_EQUAL (ligne: %d)\n", yylineno); column_counter += yyleng; return GREATER_OR_EQUAL; }
":"                 { printf("TOKEN: COLON (ligne: %d)\n", yylineno); column_counter += yyleng; return COLON; }
"and"               { printf("TOKEN: LOGICAL_AND (ligne: %d)\n", yylineno); column_counter += yyleng; return AND; }
"or"                { printf("TOKEN: LOGICAL_OR (ligne: %d)\n", yylineno); column_counter += yyleng; return OR; }
"not"               { printf("TOKEN: NOT (ligne: %d)\n", yylineno); column_counter += yyleng; return NOT; }

 /* Parenthèses */
"("                 { printf("TOKEN: LEFT_PARENTHESIS (ligne: %d)\n", yylineno); column_counter += yyleng; return LEFT_PARENTHESIS; }
")"                 { printf("TOKEN: RIGHT_PARENTHESIS (ligne: %d)\n", yylineno); column_counter += yyleng; return RIGHT_PARENTHESIS; }

 /* Symboles spéciaux */
"{"                 { printf("TOKEN: LEFT_BRACE (ligne: %d)\n", yylineno); column_counter += yyleng; return LEFT_BRACE; }
"}"                 { printf("TOKEN: RIGHT_BRACE (ligne: %d)\n", yylineno); column_counter += yyleng; return RIGHT_BRACE; }
";"                 { printf("TOKEN: SEMICOLON (ligne: %d)\n", yylineno); column_counter += yyleng; return SEMICOLON; }
","                 { printf("TOKEN: COMMA (ligne: %d)\n", yylineno); column_counter += yyleng; return COMMA; }
\.                  { printf("TOKEN: DOT (ligne: %d)\n", yylineno); column_counter += yyleng; return DOT; }
"<HTPL>"            { printf("TOKEN: HTPL_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return HTPL_BEGIN; }
"</HTPL>"           { printf("TOKEN: HTPL_END (ligne: %d)\n", yylineno); column_counter += yyleng; return HTPL_END; }

 /* Espaces et nouvelles lignes */
[ \t]+              { column_counter += yyleng; } /* ignorer les espaces et tabulations */
\r|\n|\r\n          { yylineno++;  column_counter = 1; }

 /* Commentaires */
"#"[^\n]*           ; /* ignorer les commentaires */

 /* Identifiants */
{ID} {
    printf("TOKEN: IDENTIFIER(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;

    Symbol *symbol = createSymbol(&symbolsTable, symbolsTable.size + 1, yytext);
    createAttribute(&symbol->attributes, "category", "unknown");

    return IDENTIFIER;
}

 /* Gestion des erreurs */
.                   { printf("File \"%s\", line %d, character %d: Lexical Error, unknown character '%s'\n", filename, yylineno, column_counter, yytext); column_counter += yyleng; return ERROR; }

%%


/* *** *** section de code *** *** */

int yywrap() {
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    filename = argv[1];
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Error opening the file: %s\n", argv[1]);
        return 1;
    }

    yyset_in(file);

    initializeSymbolsTable(&symbolsTable);

    Token token;
    do {
        token = yylex();
    } while((token != END_OF_FILE) && (token != ERROR));

    fclose(file);

    printf("\n");
    printSymbolsTable(&symbolsTable);
    printf("\n");

    deleteSymbolsTable(&symbolsTable); // this should be moved to the end of the compilation process
    
    return 0;
}
