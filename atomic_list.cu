#include <stdio.h>

#define N 1000000

__device__ unsigned size;
__device__ int list[N];

__global__ void kernel() {
	int id=blockIdx.x*blockDim.x + threadIdx.x;

	list[atomicInc(&size,N)] = id;

}

__global__ void print_kernel() {
	int i;
	printf("CURRENT SIZE IS %d\n",size);
	for(i=0;i<size;i++)
		printf("list[%d] = %d\n",i,list[i]);
}

int main(){
	cudaMemset(&size, 0, sizeof(int));

	kernel<<<4,64>>>();

	cudaDeviceSynchronize();

	print_kernel<<<1,1>>>();

	cudaDeviceSynchronize();
	return 0;
}
