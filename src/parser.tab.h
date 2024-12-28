/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TYPE_INTEGER = 258,            /* TYPE_INTEGER  */
    TYPE_FLOAT = 259,              /* TYPE_FLOAT  */
    TYPE_BOOLEAN = 260,            /* TYPE_BOOLEAN  */
    TYPE_CHAR = 261,               /* TYPE_CHAR  */
    TYPE_STRING = 262,             /* TYPE_STRING  */
    VOID = 263,                    /* VOID  */
    INTEGER_LITERAL = 264,         /* INTEGER_LITERAL  */
    FLOAT_LITERAL = 265,           /* FLOAT_LITERAL  */
    BOOLEAN_LITERAL = 266,         /* BOOLEAN_LITERAL  */
    CHAR_LITERAL = 267,            /* CHAR_LITERAL  */
    STRING_LITERAL = 268,          /* STRING_LITERAL  */
    PLUS = 269,                    /* PLUS  */
    MINUS = 270,                   /* MINUS  */
    MULTIPLY = 271,                /* MULTIPLY  */
    DIVIDE = 272,                  /* DIVIDE  */
    MODULO = 273,                  /* MODULO  */
    AND = 274,                     /* AND  */
    OR = 275,                      /* OR  */
    NOT = 276,                     /* NOT  */
    EQUAL = 277,                   /* EQUAL  */
    NOT_EQUAL = 278,               /* NOT_EQUAL  */
    LESS = 279,                    /* LESS  */
    LESS_OR_EQUAL = 280,           /* LESS_OR_EQUAL  */
    GREATER = 281,                 /* GREATER  */
    GREATER_OR_EQUAL = 282,        /* GREATER_OR_EQUAL  */
    LEFT_PARENTHESIS = 283,        /* LEFT_PARENTHESIS  */
    RIGHT_PARENTHESIS = 284,       /* RIGHT_PARENTHESIS  */
    LEFT_BRACE = 285,              /* LEFT_BRACE  */
    RIGHT_BRACE = 286,             /* RIGHT_BRACE  */
    LEFT_BRACKET = 287,            /* LEFT_BRACKET  */
    RIGHT_BRACKET = 288,           /* RIGHT_BRACKET  */
    COLON = 289,                   /* COLON  */
    SEMICOLON = 290,               /* SEMICOLON  */
    DOT = 291,                     /* DOT  */
    COMMA = 292,                   /* COMMA  */
    RETURN = 293,                  /* RETURN  */
    ASSIGN = 294,                  /* ASSIGN  */
    LET = 295,                     /* LET  */
    IDENTIFIER = 296,              /* IDENTIFIER  */
    HTPL_BEGIN = 297,              /* HTPL_BEGIN  */
    HTPL_END = 298,                /* HTPL_END  */
    FUNCTION_BEGIN = 299,          /* FUNCTION_BEGIN  */
    FUNCTION_END = 300,            /* FUNCTION_END  */
    FUNCTION_NAME = 301,           /* FUNCTION_NAME  */
    MAIN = 302,                    /* MAIN  */
    READ = 303,                    /* READ  */
    WRITE = 304,                   /* WRITE  */
    IF_BEGIN = 305,                /* IF_BEGIN  */
    IF_END = 306,                  /* IF_END  */
    ELSE = 307,                    /* ELSE  */
    WHILE_BEGIN = 308,             /* WHILE_BEGIN  */
    WHILE_END = 309,               /* WHILE_END  */
    STRUCT_BEGIN = 310,            /* STRUCT_BEGIN  */
    STRUCT_END = 311,              /* STRUCT_END  */
    NEG = 312                      /* NEG  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 34 "parser.y"

    int int_t;
    float float_t;
    bool boolean_t;
    char char_t;
    char *string_t;

#line 129 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
