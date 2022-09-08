#include <stdio.h>

__global__ void initToZero(int *a){
	a[threadIdx.x]=threadIdx.x;
}

__global__ void addOne(int * d_a){
	d_a[threadIdx.x] += threadIdx.x;
}

__global__ void newAddOne(int *a){

	int tid;
	tid=blockIdx.x*blockDim.x+threadIdx.x;

	if((tid > 8000) || (tid < 1024))
		return;
	
	printf("Thread ID here is %d\n",tid);
	a[tid]+=tid;

}

int main(){

	int *a, *d_a;

	a=(int*)malloc(8000*sizeof(int));

	cudaMalloc(&d_a,32*sizeof(int));

//	cudaMemcpy(d_a, a, sizeof(int)*32, cudaMemcpyHostToDevice);

	initToZero<<<1,32>>>(d_a);

//	cudaDeviceSynchronize();

	cudaMemcpy(a, d_a, sizeof(int)*32, cudaMemcpyDeviceToHost);

	cudaFree(d_a);
	
	cudaMalloc(&d_a,1024*sizeof(int));
	
	addOne<<<1,1024>>>(d_a);

	cudaMemcpy(a, d_a, sizeof(int)*1024, cudaMemcpyDeviceToHost);


	cudaFree(d_a);

	cudaMalloc(&d_a,8000*sizeof(int));

	cudaMemcpy(a, d_a, sizeof(int)*1024, cudaMemcpyDeviceToHost);

	newAddOne<<<ceil((8000-1024)/1024),1024>>>(d_a);

	cudaMemcpy(a, d_a, sizeof(int)*8000, cudaMemcpyDeviceToHost);

	printf("CHECK A[7999] %d\n",a[7999]);
	return 0;
}
