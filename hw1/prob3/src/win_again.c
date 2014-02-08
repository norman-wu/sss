/*
 * Code to generate shellcode to make a file called 
 * foobar.txt with contents "I win again!"
 *
 * John Filleau
 * 18-732
 * Spring 2014
*/

int main() {

  system("echo 'I win again!' > foobar.txt");

  return 0;
}
