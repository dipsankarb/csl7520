
#include<stdio.h>
#define N 1000000
#define BLOCK 1024

__global__ void init_kernel(int *a){
	int id;
	id=blockIdx.x*blockDim.x+threadIdx.x;

	if(id<N) 
		a[id]=id;
}

int main(){
	int *a,*d_a,i;
	int nblocks;

	cudaMalloc(&d_a,N*sizeof(int));

	a=(int*)malloc(N*sizeof(int));

	nblocks=ceil(N/BLOCK);
	printf("NUMBER OF BLOCKS %d\n",nblocks);

	init_kernel<<<nblocks+1, BLOCK>>>(d_a);

	cudaMemcpy(a, d_a, N*sizeof(int), cudaMemcpyDeviceToHost);

	for(i=1; i<11 ; i++)
		printf("%d ", a[N-i]);

	return 0;
}
