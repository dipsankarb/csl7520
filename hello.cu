#include<stdio.h>
#define N 10

__device__ void deviceFunc(){

}

__global__ void deviceKernel(){
	printf("Hello World");
}

__global__ void gpuDoSomething(){
	int i;
	//for(i=0; i<N; i++)
	//	printf("%d\n",i*i);

	printf("%d\n",threadIdx.x*threadIdx.x);
}

void doSomething()
{
	int i;
	for(i=0; i<N; i++){
		printf("%d\n",i*i);
	}
}

int main(){
	//deviceKernel<<<1,32>>>();
	
	//cudaDeviceSynchronize();

	doSomething();

	printf("CALL GPU DO SOMETHING\n");

	gpuDoSomething<<<1, N>>>();

	cudaDeviceSynchronize();

	return 0;
}
