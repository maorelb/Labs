#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
typedef struct virus {
    unsigned short SigSize;
    unsigned char virusName[16];
    char sig[];
} virus;
typedef struct link link;
 struct link {
    link *nextVirus;
    virus *vir;
};
void list_print(link *virus_list); 
link* list_append(link* virus_list, virus* data); 
void list_free(link *virus_list);
void printVirus(virus* v);
void loadSignatures(link* list);


int main(int argc, char** argv){
	char* input;
    int x;
	link* list=malloc(sizeof(struct link));
	// printf("1) Load signatures\n");
	// printf("2) Print signatures\n");
	// printf("3) Quit\n");
	loadSignatures(list);
	printf("Virus Name: %s\n",list->vir->virusName);
	
	// while(1){
    // fgets(input,INT_MAX,stdin);
    // x=atoi(input);
	// if(x==1)
	// 	l=loadSignatures();
	// else if(x==2)
	// 	list_print(l);
	// else{ //x==3
	// 	list_free(l);
	// 	exit(0);
	// }
	//}

	return 0;
}

void loadSignatures(link* list){
FILE *fp=fopen("signatures","rb");
	unsigned char structSize[2];
	char virusName[16];
	unsigned short size;
	unsigned int pos=0;
	if(!fp){
		printf("could not open file\n");
		exit(1);
	}
	// size of the file 
	fseek(fp,0,SEEK_END);
	long fsize=ftell(fp);
	fseek(fp,0,SEEK_SET);

	while(fsize>0){ // while there's viruses to read

		//** read the first two bytes = size 
		fread(structSize,1,2,fp);
		size = ((structSize[1] << 8) &0xFF00) | (structSize[0] & 0xFF);
		fsize =fsize -size;

		//**read the next 16 bytes = the virus name
		fseek(fp,pos+2,SEEK_SET);
		fread(virusName,1,16,fp);

		//** read next bytes = virus signature

		int signatureSize=size-18;
		unsigned char signature[signatureSize];
		fseek(fp,pos+18,SEEK_SET);
		fread(signature,1,signatureSize,fp);

		// insert to linked list
		virus* v=malloc(size);
		v->SigSize=signatureSize;
		strcpy(v->virusName, virusName);
		strcpy(v->sig, signature);
		list_append(list,v);

		// go to the next virus position
		pos=pos+size;
		fseek(fp,pos,SEEK_SET);
	}
	
	fclose(fp);
}


//adding a new link to the end of the list
link* list_append(link* virus_list, virus* data){

	// advance to the end of the list 
	link* current=virus_list;
	while(current->nextVirus!=NULL)
		current=current->nextVirus;
	
	//add a new element
	current->nextVirus=malloc(sizeof(struct link));
	current->nextVirus->vir=data;
	current->nextVirus->nextVirus=NULL;
}

//free memory allocated by list
void list_free(link *virus_list){
	link* current=virus_list;
	while(current->nextVirus!=NULL)
		free(current->vir);

	free(current);
}

//prints the list
void list_print(link *virus_list){
	link* current=virus_list;
	while(current->nextVirus!=NULL){
		printf("Virus Name: %s\n",current->vir->virusName);
		printf("Virus signature size: %d\n",current->vir->SigSize);
		for(int i=0;i<current->vir->SigSize;i++)
			printf("%02x ",current->vir->sig[i]);
		printf("\n");
	}
}

