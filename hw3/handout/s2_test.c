#include <stdio.h>
#include <string.h>



int main(int argc, char **argv)
{
  char buf1[1024];
  char buf2[512];
  char buf3[512];
  char *buf;
  int r;
  if((buf = gets(buf1)) != buf1){
    printf("gets error");
  }
  /* strcpy */
  strcpy(buf2, buf1);
  
  /* sprintf */
  sprintf(buf3, "some output");
  
  /* rand */
  r = rand();
  return 0;
}

