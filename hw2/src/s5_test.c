#include <string.h>


int main(int argc, char **argv)
{
  char buf1[1024];
  char buf2[1024];
  char buf3[2048];
  strncat(buf1, buf2, 2048);   //BUG 1
  strncat(buf1, buf2, 1024);  //BUG 2
  strncat(buf3, buf2, 1024);  //NOT BUG 3
  return 0;
}


