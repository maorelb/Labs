#include <stdio.h>
#include <stdlib.h>
					/* enough to get 32-bit string + '\n' + null terminator */
extern int assFunc(int x, int y); /* extern assembly function */

char c_checkValidity(int x, int y){
	/*
	performs the following steps:
    returns false if x is negative
    returns false if y is non-positive or greater than 2^15
    returns true otherwise 
	*/

	if (x < 0){
		return '0';
	}
	if (y <= 0){
		return '0';
	}
	if (y > 32768){
		return '0';
	}
	return '1';
}

int main(int argc, char** argv)
{
	//Get input from the user:
	char cx[11];
	fgets(cx,11,stdin);
	int x;
	x = atoi(cx);        
	char cy[11];
	fgets(cy,11,stdin);
	int y;
	y = atoi(cy);
  assFunc(x,y);	/* call your assembly function */
	

  return 0;
}
