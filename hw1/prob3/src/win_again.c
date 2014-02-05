/*
 * Code to generate shellcode to make a file called 
 * foobar.txt with contents "I win again!"
 *
 * John Filleau
 * 18-732
 * Spring 2014
*/

#include <stdio.h>

  char *filename = "foobar.txt";
  char *contents = "I win again!";
  char *write_flag = "w";

int main() {

  FILE *fp;
  fp=fopen(filename, write_flag);
  fprintf(fp, contents);
  fclose(fp);

  return 0;
}
