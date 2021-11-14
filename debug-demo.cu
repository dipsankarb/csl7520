#include <stdio.h>

__global__ void kernel(int *x){
	*x=0;
	printf("%d\n",*x);
}

int main(){

	int *x;
	kernel<<<2,10>>>(x);
	cudaDeviceSynchronize();

	//cudaError_t err = cudaGetLastError();
	//printf("error is %d, %s, %s\n",err,cudaGetErrorName(err),cudaGetErrorString(err));

	return 0;
}
