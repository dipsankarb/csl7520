#include<stdio.h>
#define BLOCK 1024

__global__ void dKernel(int *a){
	__shared__ int s;

	if(threadIdx.x == 0) s=0; // WARP X
	__syncthreads();

	if(threadIdx.x == 1) s+=1; // WARP Y
	__syncthreads();

	if(threadIdx.x == 100) s+=2; //WARP Z
	__syncthreads();

	//if(threadIdx.x == 0) *a=s; // WARP K
	if(threadIdx.x == 0) printf("S IS %d\n",s);; // WARP K
}
int main(){

	int *d_a,a,i;
	cudaMalloc(&d_a,sizeof(int));

	for(i=0;i<100;i++){
		dKernel<<<2,BLOCK>>>(d_a);
		cudaDeviceSynchronize();
	}

	cudaMemcpy(&a,d_a,sizeof(int),cudaMemcpyDeviceToHost);
//	printf("S IS %d\n",a);

	return 0;
}
