/*
 * Code to generate shellcode to make a file called 
 * foobar.txt with contents "I win again!"
 *
 * John Filleau
 * 18-732
 * Spring 2014
*/

#include <stdio.h>

int main() {

  char filename[11] = "foobar.txt\0";
  char content[13]  = "I win again!\0";
  char write[2]     = "w\0";

  FILE *fp;
  fp=fopen(filename, write);
  fprintf(fp, content);
  fclose(fp);

  return 0;
}
