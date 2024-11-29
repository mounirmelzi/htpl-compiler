/* *** *** section de definition *** *** */

%{

int cpt = 0;

%}



/* *** *** section des actions *** *** */

%%

\n {
    printf("Hello World !\n");
    return 0;
}

%%



/* *** *** section de code *** *** */

int yywrap() {
}


int main(int argc, char* argv[]) {
    yylex();
    return 0;
}
