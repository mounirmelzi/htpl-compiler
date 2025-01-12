#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "quadruplets.h"

quad *creerQuadreplet(char opr[30],char op1[30],char op2[30],char res[30],int num){
    quad *q = (quad *)malloc(sizeof(quad));
    strcpy(q->operateur,opr);
    strcpy(q->operande1,op1);
    strcpy(q->operande2,op2);
    strcpy(q->resultat,res);
    q->qc=num;
    q->suivant=NULL;
    return q;
}

void insererQuadreplet(quad **p,char opr[],char op1[],char op2[],char res[],int num) {  
    quad *q;
    if(*p==NULL){
        *p=creerQuadreplet(opr,op1,op2,res,num);
    }else{
    q = (quad *)malloc(sizeof(quad));
    strcpy(q->operateur,opr);
    strcpy(q->operande1,op1);
    strcpy(q->operande2,op2);
    strcpy(q->resultat,res);
    q->qc=num;
    q->suivant = *p;
    *p = q;
    }
}

void ajouterQuadreplet(quad ** q,quad * nouveauQuadreplet,int num){
    if(nouveauQuadreplet == NULL)
        return;

    if (q != NULL){
        nouveauQuadreplet->qc=num;
        nouveauQuadreplet->suivant = *q;
    }
    *q = nouveauQuadreplet;
}   


// mise a jour du quad numero qc dans le quad *(l'ensemble des quadreplets)
void updateQuadreplet(quad *q, int qc,char num[30]){
    quad *p = q;
    if (p==NULL){
        return ;
    }
    while(p!=NULL){
        if(p->qc==qc){
            strcpy(p->operande1,num);
            return ;
        }
        p=p->suivant;
    }
}

void checkTypeCompatibility(const char* op1, const char* op2) {
    if (!op1 || !op2) {
        fprintf(stderr, "Error: One or both operands are undefined (%s, %s)\n", op1, op2);
        exit(EXIT_FAILURE);
    }

    if (strcmp(op1, op2) != 0) {
        fprintf(stderr, "Error: Type mismatch between (%s) and (%s)\n",
                op1, op2);
        exit(EXIT_FAILURE);
    }
}

void afficherQuadsRecursion(quad * q){
    if(q == NULL){
        return;
    }
    afficherQuadsRecursion(q->suivant);
    printf("\t Quad[%d]=[ %s , %s , %s , %s ] \n",q->qc,q->operateur,q->operande1,q->operande2,q->resultat);

}

void afficherQuad(quad *q)
{
    quad * p;
    p = q;
    printf("\n=============  Affichage des quadruplets =============\n");
    if (q==NULL){
        printf("\n\n \t\t quad *Vide \n");
    }else{
        printf("___________________________________________________\n\n");
        afficherQuadsRecursion(p);
    }
    printf("___________________________________________________\n");
}

void supprimerQuadruplet(quad **q, int qc) {
    quad *current = *q;
    quad *prev = NULL;

    // Traverse the list to find the quadruplet with the specified qc
    while (current != NULL && current->qc != qc) {
        prev = current;
        current = current->suivant;
    }

    // If the quadruplet is found
    if (current != NULL) {
        // If the quadruplet to be deleted is the head of the list
        if (prev == NULL) {
            *q = current->suivant;
        } else {
            prev->suivant = current->suivant;
        }
        free(current);
    }
}