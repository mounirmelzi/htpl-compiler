/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "parser.h"
#include "symbols_table.h"


extern char *filename;

int column_counter = 1;

%}



/* *** *** les options de flex *** *** */

%option noyywrap



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
"main"              {
    printf("TOKEN: MAIN (ligne: %d)\n", yylineno);
    column_counter += yyleng;
    yylval.string_t = strdup(yytext);
    return MAIN;
}

_{ID}               {
    printf("TOKEN: FUNCTION_NAME(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;
    yylval.string_t = strdup(yytext);
    return FUNCTION_NAME;
}

 /* Boucles et conditions */
"<if"               { printf("TOKEN: IF_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return IF_BEGIN; }
"</if>"             { printf("TOKEN: IF_END (ligne: %d)\n", yylineno); column_counter += yyleng; return IF_END; }
"<else>"            { printf("TOKEN: ELSE (ligne: %d)\n", yylineno); column_counter += yyleng; return ELSE; }
"<while"            { printf("TOKEN: WHILE_BEGIN (ligne: %d)\n", yylineno); column_counter += yyleng; return WHILE_BEGIN; }
"</while>"          { printf("TOKEN: WHILE_END (ligne: %d)\n", yylineno); column_counter += yyleng; return WHILE_END; }

 /* Types */
"int"               { printf("TOKEN: TYPE_INTEGER (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_INTEGER; }
"float"             { printf("TOKEN: TYPE_FLOAT (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_FLOAT; }
"string"            { printf("TOKEN: TYPE_STRING (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_STRING; }
"boolean"           { printf("TOKEN: TYPE_BOOLEAN (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_BOOLEAN; }
"char"              { printf("TOKEN: TYPE_CHAR (ligne: %d)\n", yylineno); column_counter += yyleng; return TYPE_CHAR; }
"void"              { printf("TOKEN: VOID (ligne: %d)\n", yylineno); column_counter += yyleng; return VOID; }

 /* Littéraux */
{DIGIT}+            {
    printf("TOKEN: INTEGER_LITERAL(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;
    yylval.int_t = atoi(yytext);
    return INTEGER_LITERAL;
}

{DIGIT}+"."{DIGIT}+ {
    printf("TOKEN: FLOAT_LITERAL(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;
    yylval.float_t = atof(yytext);
    return FLOAT_LITERAL;
}

 /* traietement d'une chaine de caractere */
\"([^\"\\]|\\.)*\" {
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
                    fprintf(stderr, "Warning: Unknown escape sequence '\\%c' at line %d\n", yytext[i], yylineno);
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
    yylval.string_t = strdup(processed);
    return STRING_LITERAL;
}

"true"|"false"      {
    printf("TOKEN: BOOLEAN_LITERAL(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;
    yylval.boolean_t = (strcmp(yytext, "true") == 0);
    return BOOLEAN_LITERAL;
}

'.'                 {
    printf("TOKEN: CHAR_LITERAL(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;
    yylval.char_t = yytext[0];
    return CHAR_LITERAL;
}

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
{ID}                {
    printf("TOKEN: IDENTIFIER(%s) (ligne: %d)\n", yytext, yylineno);
    column_counter += yyleng;
    yylval.string_t = strdup(yytext);
    return IDENTIFIER;
}

 /* Gestion des erreurs */
.                   { printf("File \"%s\", line %d, character %d: lexical error, unknown character '%s'\n", filename, yylineno, column_counter, yytext); return YYUNDEF; }

%%
