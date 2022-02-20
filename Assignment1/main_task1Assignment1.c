#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#define	MAX_LEN 34			/* maximal input string size */
					/* enough to get 32-bit string + '\n' + null terminator */
extern int convertor(char* buf);
int main(int argc, char** argv)
{
  char buf[MAX_LEN ];
  while(1){
  	fgets(buf, MAX_LEN, stdin);
  	if(strncmp(buf,"q",1)==0)
  		exit(0);
  	convertor(buf);
	}

  return 0;
}
