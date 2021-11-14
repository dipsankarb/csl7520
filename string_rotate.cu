
#include<stdio.h>
#define BLOCK 26

__global__ void deviceKernel(){

	int id;
	id=blockIdx.x*blockDim.x+threadIdx.x;

	char str[27];
	
	str[threadIdx.x]='A'+(blockIdx.x+threadIdx.x)%26;

	str[26]='\0';

	__syncthreads();

	if(threadIdx.x==0)
		printf("%s\n",str);
}	

int main(){
	cudaFuncSetCacheConfig(deviceKernel, cudaFuncCachePreferEqual);

	deviceKernel<<<26, BLOCK>>>();

	cudaThreadSynchronize();


	return 0;
}
