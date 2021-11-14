#include<stdio.h>

__device__ int global=0;

__host__ __device__ void add(){
	printf("This can run both on CPU and GPU\n");
	printf("GLOBAL FROM HOST DEVICE IS %d\n",global++);
}

__device__ void dkernel2(){
	printf("I am ANOTEHR device function\n");
	global++;
}


__device__ void dkernel(){
	printf("I am a device function\n");
	add();
	dkernel2();
	global++;
}

__global__ void kernel(int *c){
	++*c;
	printf("Counter on GPU %d\n",*c);
	dkernel();
	global++;
}

int main(){
	int *counter;

	cudaMallocHost(&counter, sizeof(int), 0);
	
	*counter=0;

	add();

	do{
		printf("Counter on CPU %d\n",*counter);
		kernel<<<1,1>>>(counter);
		cudaDeviceSynchronize();
		++*counter;
	}while(*counter<10);

	//printf("GLOBAL IS %d\n",global);

	return 0;
}
