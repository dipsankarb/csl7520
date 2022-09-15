#include <stdio.h>
#include <omp.h>
#define N 512
#define M 10
#define in(i,j) ((i*N)+j)

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

__global__ void kernelV1(int *m){

	int tid;
	tid=blockIdx.x*blockDim.x+threadIdx.x;
	m[tid]=tid;
}

__global__ void squareGPUv1(int *m, int *res){
	int tid,j,k;
	tid=threadIdx.x+blockIdx.x*blockDim.x;
	for(j=0;j<blockDim.x;j++){
		for(k=0;k<blockDim.x;k++){
			res[in(tid,j)] += m[in(tid,k)]*m[in(k,j)];
		}
	}
	
}

__global__ void squareGPUv2(int *m, int *res){
	int tid,j,k,ii;

	tid=threadIdx.x+blockIdx.x*blockDim.x;
	j=tid%N;
	ii=tid/N;
	
	for(k=0;k<blockDim.x;k++){
			res[in(ii,j)] += m[in(ii,k)]*m[in(k,j)];
	}
}


void squareCPU(int *m, int *res){

	int i,j,k;

	for(i=0;i<N;i++){
		#pragma parallel for num_threads(16)
		for(j=0;j<N;j++){
			for(k=0;k<N;k++){
				res[in(i,j)] += m[in(i,k)]*m[in(k,j)];
			}
		}
	}

}
int main(){

	int *m, *d_m, *res, *d_res, i,j;
	clock_t start, stop;
	float ms;

	omp_set_num_threads(20);

	cudaEvent_t s,p;

	cudaEventCreate(&s);
	cudaEventCreate(&p);

	m=(int*)malloc(N*N*sizeof(int));
	res=(int*)malloc(N*N*sizeof(int));
	cudaMalloc(&d_m,sizeof(int)*N*N);
	cudaMalloc(&d_res,sizeof(int)*N*N);

	kernelV1<<<N,N>>>(d_m);

	cudaMemcpy(m,d_m,N*N*sizeof(int),cudaMemcpyDeviceToHost);

/*	for(i=0; i<N; i++){
		for(j=0; j<N; j++){
			printf("%d ",m[in(i,j)]);
		}
		printf("\n");
	}*/


	start=clock();
	squareCPU(m,res);
	stop=clock();

	printf("Time taken on CPU is %lf\n",((double)(stop-start)/CLOCKS_PER_SEC)*1e3);

/*	for(i=0; i<N; i++){
		for(j=0; j<N; j++){
			printf("%d ",res[in(i,j)]);
		}
		printf("\n");
	}*/

	cudaEventRecord(s);

	squareGPUv1<<<1,N>>>(d_m,d_res);

	cudaEventRecord(p);
	cudaEventSynchronize(p);
	gpuErrchk( cudaPeekAtLastError() );

	cudaEventElapsedTime(&ms,s,p);
	printf("Time taken on GPU v1 kernel is %f\n",ms);

	cudaEventRecord(s);

	squareGPUv2<<<N,N>>>(d_m,d_res);

	cudaEventRecord(p);
	cudaEventSynchronize(p);
	gpuErrchk( cudaPeekAtLastError() );

	cudaEventElapsedTime(&ms,s,p);
	printf("Time taken on GPU v2 kernel is %f\n",ms);


	return 0;
}
