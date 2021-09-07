#include<stdio.h>
#define N 1025

__global__ void init(int *a, int *b) {
	int id=threadIdx.x;
	a[id]=0;
	b[id]+=1;
}

__global__ void assign(int *a){
	int id=threadIdx.x;
	a[id]=id;
}

int main() {
	int a[N], i;

	int *d_a;

	cudaMalloc(&d_a, N*sizeof(int));

	init<<<1,N>>>(d_a);

	cudaDeviceSynchronize();

	assign<<<1,N>>>(d_a);


	cudaMemcpy(a, d_a, sizeof(int)*N, cudaMemcpyDeviceToHost);

	for(i=0; i<N; i++)
		printf("%d ",a[i]);

	return 0;
}
