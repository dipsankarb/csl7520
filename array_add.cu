#include<stdio.h>
#define N 1000


__global__ void squaring(int *a) {
	a[threadIdx.x]=(threadIdx.x+1)*(threadIdx.x+1);
	printf("%s",msg);
}

int main() {
	int a[N],i;
	int *d_a;

	cudaMalloc(&d_a, N*sizeof(int));

	for(i=0; i<N; i++)
		a[i]=i+1;

	cudaMemcpy(d_a, a,  N*sizeof(int), cudaMemcpyHostToDevice);

	squaring<<<1,N>>>(d_a);

	cudaMemcpy(a, d_a, N*sizeof(int), cudaMemcpyDeviceToHost);

	//COMPUTATIONS AFTER THE MEMCPY

	for(i=0; i<N; i++){
		printf("%d\n",a[i]);
	}

	cudaFree(d_a);

	return 0;
}
