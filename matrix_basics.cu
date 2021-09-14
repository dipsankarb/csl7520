#include<stdio.h>
#define N 5
#define M 6

void matrix_init_cpu(int *a){

	int i,j,c=0;

	for(i=0; i<N; i++)
		for(j=0;j<M;j++)
			a[i*M+j] = c++;
}

__global__ void device_kernel(){
//	if(threadIdx.x == 0 && blockIdx.x==0 &&
//		threadIdx.y == 0 && blockIdx.y ==0 &&
//		threadIdx.z == 0 && blockIdx.z == 0)
	if(threadIdx.x == 0)
		printf("%d %d %d %d %d %d\n",gridDim.x, gridDim.y, gridDim.z, blockDim.x, blockDim.y, blockDim.z);
}

__global__ void matrix_init_gpu(int *a){
	int id = blockDim.x*blockIdx.x + threadIdx.x;
	a[id]=id;
}

int main(){
	int i,j;
	//dim3 grid(2,3,4);

	//dim3 block(5,6,7);

	//device_kernel<<<grid,block>>>();

	dim3 block(N,M,1);

	int *a = (int*)malloc(N*M*sizeof(int));
	int *d_a;

	cudaMalloc(&d_a, N*M*sizeof(int));

	//matrix_init_cpu(a);

	matrix_init_gpu<<<N, M>>>(d_a);

	cudaMemcpy(a, d_a, N*M*sizeof(int), cudaMemcpyDeviceToHost);

	for(i=0;i<N;i++){
		for(j=0;j<M;j++){
			printf("%d ",a[i*M+j]);
		}
		printf("\n");
	}

	cudaDeviceSynchronize();

	return 0;
}
