#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dlfcn.h> // to load and use mycode at runtime

int main() {
char str[6];
int a, b;

while(scanf("%5s %d %d", str, &a, &b) == 3){  // use 5s to make sure there is no overflow
char library[20];
int i = 0;
library[i++]='l';
library[i++]='i';
library[i++]='b';
for (int j=0;str[j];j++){
    library[i++]=str[j];
}
library[i++]='.';
library[i++]='s';
library[i++]='o';
library[i]='\0';

void *handle = dlopen(library, RTLD_LAZY); // to  bring the library into memory
if(handle==NULL){
continue;
}

int(*oper)(int, int);
oper = dlsym(handle, str);// get a pointer to operation that needs to be performed

if(!oper){
dlclose(handle);
continue;
}

int result = oper(a, b);
printf("%d\n", result);
dlclose(handle);
}

return 0;
}