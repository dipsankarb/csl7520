#include<stdio.h>

__global__ void deviceKernel(){
	printf("Hello World");
}

int main(){
	deviceKernel<<<1,32>>>();
	cudaDeviceSynchronize();

	return 0;
}
