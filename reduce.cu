
#include<stdio.h>

#define N 1024
#define BLOCK 1024

__global__ void reduceV1(int *elems){
	int id,i;
	id=threadIdx.x+blockIdx.x*blockDim.x;
	for(i=N/2; i; i/=2) {
		if(id<i)
			elems[id] += elems[id+i];
		__syncthreads();
	}
	if(id==0)
		printf("GPU Sum is %d\n",elems[0]);
}

int main(){
	int host[N],i;
	long int sum=0;

	for(i=0;i<N;i++){
		host[i]=rand()%20;
		sum+=host[i];
	}	

	printf("CPU Sum is %d\n",sum);

	int *d_elems;
	cudaMalloc(&d_elems,N*sizeof(int));

	cudaMemcpy(d_elems,host,N*sizeof(int),cudaMemcpyHostToDevice);

	reduceV1<<<(N+BLOCK-1)/BLOCK,BLOCK>>>(d_elems);
	cudaDeviceSynchronize();

	return 0;
}
