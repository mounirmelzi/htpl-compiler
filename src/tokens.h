#ifndef TOKENS_H
#define TOKENS_H

/* Mots-clés */
#define LET 1
#define RETURN 2
#define WRITE 3
#define READ 4

/* Types */
#define TYPE_INT 5
#define TYPE_FLOAT 6
#define TYPE_STRING 7
#define TYPE_BOOLEAN 8
#define TYPE_CHAR 9

/* Identifiants et Littéraux */
#define IDENTIFIER 10
#define INTEGER_LITERAL 11
#define FLOAT_LITERAL 12
#define STRING_LITERAL 13
#define BOOLEAN_LITERAL 14
#define CHAR_LITERAL 15

/* Tableaux */
#define LBRACKET 16
#define RBRACKET 17
#define COMMA 18

/* Enregistrements (Struct) */
#define STRUCT_BEGIN 19
#define STRUCT_END 20

/* Opérateurs */
#define PLUS 21
#define MINUS 22
#define MULTIPLY 23
#define DIVIDE 24
#define MODULO 25  
#define ASSIGN 26
#define EQUAL 27
#define NOT_EQUAL 28
#define LESS 29          
#define LESS_EQUAL 30    
#define GREATER 31       
#define GREATER_EQUAL 32 
#define COLON 33
#define LOGICAL_AND 34
#define LOGICAL_OR 35
#define NOT 36

/* Parenthèses */
#define LPAREN 37        
#define RPAREN 38        

/* Symboles spéciaux */
#define LBRACE 39
#define RBRACE 40
#define HTPL_BEGIN 41
#define HTPL_END 42
#define SEMICOLON 43

/* Fonctions */
#define FUNCTION_BEGIN 44
#define FUNCTION_END 45         
#define FUNCTION_NAME 46   
#define MAIN 47

/* Boucles et conditions */
#define IF_BEGIN 48  
#define IF_END 49       
#define ELSE 50   
#define WHILE_BEGIN 51
#define WHILE_END 52  

#endif
