#include<stdio.h>
#include<string.h>
#define N 1000

__global__ void str_add(char *a, int len) {
	if(threadIdx.x < len)
		++a[threadIdx.x];
}

int main() {
	char *d_a;
//	char *str="Hello World";
	char str[]={'H', 'E', 'L', 'L', 'O', ' ', 'W', 'O', 'R', 'L', 'D'};

	cudaMalloc(&d_a, strlen(str)*sizeof(char));

	cudaMemcpy(d_a, str,  strlen(str)*sizeof(char), cudaMemcpyHostToDevice);

	str_add<<<1,32>>>(d_a, strlen(str));

	cudaMemcpy(str, d_a, strlen(str)*sizeof(char), cudaMemcpyDeviceToHost);

	//COMPUTATIONS AFTER THE MEMCPY

	printf("%s\n",str);

	cudaFree(d_a);

	return 0;
}
