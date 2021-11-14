#include<stdio.h>
#define BLOCK 1024

__global__ void deviceKernel(){
	__shared__ unsigned s;

	if(threadIdx.x==0) s=0;

	__syncthreads();

	if(threadIdx.x==1) s+=1;

	__syncthreads();

	if(threadIdx.x==100) s+=2;

	__syncthreads();

	if(threadIdx.x == 0) printf("s is %d\n",s);
}

int main(){
	int i;
	
	for(i=0;i<10;i++){
		deviceKernel<<<2,BLOCK>>>();
		cudaDeviceSynchronize();
	}
	return 0;
}
