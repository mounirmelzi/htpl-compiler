/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "tokens.h" 

%}

/* Définition des macros */
DIGIT       [0-9]
IDENT       [a-zA-Z][a-zA-Z0-9]*

/* *** *** section des actions *** *** */
%%

 /* Mots-clés */
"let"               { printf("TOKEN: LET (ligne: %d)\n", yylineno); return LET; }
"return"            { printf("TOKEN: RETURN (ligne: %d)\n", yylineno); return RETURN; }
"write"             { printf("TOKEN: WRITE (ligne: %d)\n", yylineno); return WRITE; }
"read"              { printf("TOKEN: READ (ligne: %d)\n", yylineno); return READ; }

 /* Fonctions */
"<function"         { printf("TOKEN: FUNCTION_BEGIN (ligne: %d)\n", yylineno); return FUNCTION_BEGIN; }
"</function>"       { printf("TOKEN: FUNCTION_END (ligne: %d)\n", yylineno); return FUNCTION_END; }
"main"              { printf("TOKEN: MAIN (ligne: %d)\n", yylineno); return MAIN; }
_[0-9]*{IDENT}      { printf("TOKEN: FUNCTION_NAME(%s) (ligne: %d)\n", yytext, yylineno); return FUNCTION_NAME; }

 /* Boucles et conditions */
"<if"               { printf("TOKEN: IF_BEGIN (ligne: %d)\n", yylineno); return IF_BEGIN; }
"</if>"             { printf("TOKEN: IF_END (ligne: %d)\n", yylineno); return IF_END; }
"<else>"            { printf("TOKEN: ELSE (ligne: %d)\n", yylineno); return ELSE; }
"<while"            { printf("TOKEN: WHILE_BEGIN (ligne: %d)\n", yylineno); return WHILE_BEGIN; }
"</while>"          { printf("TOKEN: WHILE_END (ligne: %d)\n", yylineno); return WHILE_END; }

 /* Types */
"int"               { printf("TOKEN: TYPE_INT (ligne: %d)\n", yylineno); return TYPE_INT; }
"float"             { printf("TOKEN: TYPE_FLOAT (ligne: %d)\n", yylineno); return TYPE_FLOAT; }
"string"            { printf("TOKEN: TYPE_STRING (ligne: %d)\n", yylineno); return TYPE_STRING; }
"boolean"           { printf("TOKEN: TYPE_BOOLEAN (ligne: %d)\n", yylineno); return TYPE_BOOLEAN; }
"char"              { printf("TOKEN: TYPE_CHAR (ligne: %d)\n", yylineno); return TYPE_CHAR; }

 /* Littéraux */
{DIGIT}+            { printf("TOKEN: INTEGER_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); return INTEGER_LITERAL; }
{DIGIT}+"."{DIGIT}+ { printf("TOKEN: FLOAT_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); return FLOAT_LITERAL; }

 /* traietement d'une chaine de caractere */
\"([^\"\\]|\\["\\nt])*\" {
    // si un caractere special est precédé par un antislash, le caractere sera concidéré comme faisant partie de la chaine.
    char processed[1024];
    int i = 0, j = 0;
    while (yytext[i] != '\0') {
        if (yytext[i] == '\\' && (yytext[i + 1] == '"' || yytext[i + 1] == '\\')) {
            processed[j++] = yytext[++i]; 
        } else if (yytext[i] != '\\') {
            processed[j++] = yytext[i]; 
        }
        i++;
    }
    processed[j] = '\0'; // terminaison de la chaîne
    printf("TOKEN: STRING_LITERAL(%s) (ligne: %d)\n", processed, yylineno);
    return STRING_LITERAL;
}

"true"|"false"      { printf("TOKEN: BOOLEAN_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); return BOOLEAN_LITERAL; }
'.'                 { printf("TOKEN: CHAR_LITERAL(%s) (ligne: %d)\n", yytext, yylineno); return CHAR_LITERAL; }

 /* Tableaux */
"["                 { printf("TOKEN: LBRACKET (ligne: %d)\n", yylineno); return LBRACKET; }
"]"                 { printf("TOKEN: RBRACKET (ligne: %d)\n", yylineno); return RBRACKET; }

 /* Enregistrements (Struct) */
"<struct"           { printf("TOKEN: STRUCT_BEGIN (ligne: %d)\n", yylineno); return STRUCT_BEGIN; }
"</struct>"         { printf("TOKEN: STRUCT_END (ligne: %d)\n", yylineno); return STRUCT_END; }

 /* Opérateurs */
"+"                 { printf("TOKEN: PLUS (ligne: %d)\n", yylineno); return PLUS; }
"-"                 { printf("TOKEN: MINUS (ligne: %d)\n", yylineno); return MINUS; }
"*"                 { printf("TOKEN: MULTIPLY (ligne: %d)\n", yylineno); return MULTIPLY; }
"/"                 { printf("TOKEN: DIVIDE (ligne: %d)\n", yylineno); return DIVIDE; }
"%"                 { printf("TOKEN: MODULO (ligne: %d)\n", yylineno); return MODULO; }
"="                 { printf("TOKEN: ASSIGN (ligne: %d)\n", yylineno); return ASSIGN; }
"=="                { printf("TOKEN: EQUAL (ligne: %d)\n", yylineno); return EQUAL; }
"!="                { printf("TOKEN: NOT_EQUAL (ligne: %d)\n", yylineno); return NOT_EQUAL; }
"<"                 { printf("TOKEN: LESS (ligne: %d)\n", yylineno); return LESS; }
"<="                { printf("TOKEN: LESS_EQUAL (ligne: %d)\n", yylineno); return LESS_EQUAL; }
">"                 { printf("TOKEN: GREATER (ligne: %d)\n", yylineno); return GREATER; }
">="                { printf("TOKEN: GREATER_EQUAL (ligne: %d)\n", yylineno); return GREATER_EQUAL; }
":"                 { printf("TOKEN: COLON (ligne: %d)\n", yylineno); return COLON; }
"and"               { printf("TOKEN: LOGICAL_AND (ligne: %d)\n", yylineno); return LOGICAL_AND; }
"or"                { printf("TOKEN: LOGICAL_OR (ligne: %d)\n", yylineno); return LOGICAL_OR; }
"not"               { printf("TOKEN: NOT (ligne: %d)\n", yylineno); return NOT; }

 /* Parenthèses */
"("                 { printf("TOKEN: LPAREN (ligne: %d)\n", yylineno); return LPAREN; }
")"                 { printf("TOKEN: RPAREN (ligne: %d)\n", yylineno); return RPAREN; }

 /* Symboles spéciaux */
"{"                 { printf("TOKEN: LBRACE (ligne: %d)\n", yylineno); return LBRACE; }
"}"                 { printf("TOKEN: RBRACE (ligne: %d)\n", yylineno); return RBRACE; }
";"                 { printf("TOKEN: SEMICOLON (ligne: %d)\n", yylineno); return SEMICOLON; }
","                 { printf("TOKEN: COMMA (ligne: %d)\n", yylineno); return COMMA; }
"<HTPL>"            { printf("TOKEN: HTPL_BEGIN (ligne: %d)\n", yylineno); return HTPL_BEGIN; }
"</HTPL>"           { printf("TOKEN: HTPL_END (ligne: %d)\n", yylineno); return HTPL_END; }

 /* Espaces et nouvelles lignes */
[ \t]+              ; /* ignorer les espaces et tabulations */
\r|\n|\r\n          { yylineno++; }

 /* Commentaires */
"#"[^\n]*           ; /* ignorer les commentaires */

 /* Identifiants */
{IDENT}             { printf("TOKEN: IDENTIFIER(%s) (ligne: %d)\n", yytext, yylineno); return IDENTIFIER; }

 /* Gestion des erreurs */
.                   { printf("Erreur lexicale : caractère inconnu '%s' à la ligne %d\n", yytext, yylineno); }

%%

/* *** *** section de code *** *** */

int yywrap() {
}


int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        fprintf(stderr, "Error opening the file: %s\n", argv[1]);
        return 1;
    }

    yyset_in(file);
    yylex();
    fclose(file);
    return 0;
}
