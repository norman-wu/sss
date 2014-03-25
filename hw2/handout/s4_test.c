#include <stdlib.h>

void foo(){
    /* correct */
    int* i = (int*) malloc(sizeof(int));
    free(i);

    /* incorrect */
    free(i);
    /* incorrect */
    free(i);

    /* correct */
    i = (int*) malloc(sizeof(int));
    free(i);

    /* incorrect */
    int* j = i;
    free(j);
}
