#pragma once

typedef enum Token
{
    ERROR = -1,
    END_OF_FILE = 0,

    /* Mots-clés */
    LET = 1,
    RETURN,
    WRITE,
    READ,

    /* Types */
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOLEAN,
    TYPE_CHAR,
    TYPE_VOID,

    /* Identifiants et Littéraux */
    IDENTIFIER,
    INTEGER_LITERAL,
    FLOAT_LITERAL,
    STRING_LITERAL,
    BOOLEAN_LITERAL,
    CHAR_LITERAL,

    /* Tableaux */
    LEFT_BRACKET,
    RIGHT_BRACKET,
    COMMA,

    /* Enregistrements (Struct) */
    STRUCT_BEGIN,
    STRUCT_END,
    DOT,

    /* Opérateurs */
    PLUS,
    MINUS,
    MULTIPLY,
    DIVIDE,
    MODULO,
    ASSIGN,
    EQUAL,
    NOT_EQUAL,
    LESS,
    LESS_OR_EQUAL,
    GREATER,
    GREATER_OR_EQUAL,
    COLON,
    AND,
    OR,
    NOT,

    /* Parenthèses */
    LEFT_PARENTHESIS,
    RIGHT_PARENTHESIS,

    /* Symboles spéciaux */
    LEFT_BRACE,
    RIGHT_BRACE,
    HTPL_BEGIN,
    HTPL_END,
    SEMICOLON,

    /* Fonctions */
    FUNCTION_BEGIN,
    FUNCTION_END,
    FUNCTION_NAME,
    MAIN,

    /* Boucles et conditions */
    IF_BEGIN,
    IF_END,
    ELSE,
    WHILE_BEGIN,
    WHILE_END
} Token;
