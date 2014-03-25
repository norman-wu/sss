#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void foo(){
    /* incorrect */
    int* i = (int*) malloc(sizeof(int));
    printf("%d\n", *i);

    /* correct */
    long* l = (long*) malloc(sizeof(long));
    if(l){
        printf("asdf %l\n", *l);
    }

    /* incorrect */
    char* s = (char*) malloc(sizeof(char)*32);
    strcpy(s, "some text");
    printf("%s\n", s);

    /* incorrect */
    char* r = (char*) malloc(sizeof(char)*32);
    strncpy(r, "some text", 32);
    printf("%s\n", r);

    /* correct */
    s = (char*) malloc(sizeof(char)*32);
    if(s){
        strcpy(s, "some text");
        printf("%s\n", s);
    }

    /* correct */
    r = (char*) malloc(sizeof(char)*32);
    if(r){
        strncpy(r, "some text", 32);
        printf("%s\n", r);
    }
}
