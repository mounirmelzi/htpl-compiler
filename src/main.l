/* *** *** section de definition *** *** */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

%}



/* *** *** section des actions *** *** */

%%

. {
    printf("%s", yytext);
}

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

    yyin = file;
    yylex();
    fclose(file);
    return 0;
}
