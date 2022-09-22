#include <stdio.h>
#define N 10000000

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

struct node1{
	int a;
	double b;
	char c;
};
struct node2{
	int a[N];
	double b[N];
	char c[N];
};

__global__ void dKernel1(node1 *arr1){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	if(tid>=N)
		return;

//	printf("WORKING ON AOS\n");
	arr1[tid].a=1+(tid*tid)/434324;
	arr1[tid].b=1.5;
	arr1[tid].c='c';

}

__global__ void dKernel2(node2 *arr2){
	int tid=blockIdx.x*blockDim.x+threadIdx.x;
	if(tid>=N)
		return;

//	printf("WORKING ON SOA\n");
	arr2->a[tid]=1+(tid*tid)/32434423;
	arr2->b[tid]=1.5;
	arr2->c[tid]='c';
//	printf("KERNEL DONE\n");
}



int main(){
	int i,j,k;
	float ms;


	node1 *d_arr1;
	node2 *d_arr2;
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);


	gpuErrchk(cudaMalloc(&d_arr1,sizeof(node1)*N));
	gpuErrchk(cudaMalloc(&d_arr2,sizeof(node2)));
	
	i=ceil(N/1024)+1;

	cudaEventRecord(start);
	dKernel1<<<i,1024>>>(d_arr1);
	cudaEventSynchronize(stop);
	cudaEventRecord(stop);
	cudaEventElapsedTime(&ms,start,stop);

	gpuErrchk( cudaPeekAtLastError() );
	printf("TIME TAKEN BY AOS %f\n",ms);


	cudaEventRecord(start);
	dKernel2<<<i,1024>>>(d_arr2);
	cudaEventSynchronize(stop);
	cudaEventRecord(stop);
	cudaEventElapsedTime(&ms,start,stop);
	gpuErrchk( cudaPeekAtLastError() );
	printf("TIME TAKEN BY SOA %f\n",ms);


	printf("EXITING\n");
	return 0;
}
