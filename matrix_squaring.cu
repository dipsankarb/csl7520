#include<stdio.h>
#include<cuda_profiler_api.h>

#define N 128

__global__ void squareMatrixGpu(double *a,double*b){
	int id,j,k;
	id = blockIdx.x*blockDim.x+threadIdx.x;
	for(j=0;j<N;j++){
		for(k=0;k<N;k++){
			b[id*N+j] += a[id*N+k]*a[id+N+j];
		}
	}
}

__global__ void squareMatrixGpuV2(double *a,double*b){
	int id,j,k,i;
	id = blockIdx.x*blockDim.x+threadIdx.x;
	i=id/N;
	j=id%N;
	for(k=0;k<N;k++){
		b[i*N+j] += a[i*N+k]*a[i+N+j];
	}
}


void squareMatrix(double *a, double *b){

	int i,j,k;

	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			for(k=0;k<N;k++){
				b[i*N+j]+=a[i*N+k]*a[k*N+j];
			}
		}
	}
}

int main() {

	double *a=(double*)malloc(N*N*sizeof(double));
	double *result=(double*)malloc(N*N*sizeof(double));

	double *d_a,*d_result;
	float ms=0;
	clock_t start,stop;
	int i,j,k;

	cudaEvent_t st,end;

	cudaEventCreate(&st);
	cudaEventCreate(&end);

	
	for(i=0;i<N*N;i++){
		a[i]=(double)rand()/RAND_MAX*2.0-1.0;
		result[i]=0;
	}
	
	start=clock();
	squareMatrix(a,result);
	stop=clock();

	printf("Time taken to multiply on CPU %lf ms\n",((double)(stop-start)/CLOCKS_PER_SEC)*1000);

	cudaMalloc(&d_a,N*N*sizeof(double));
	cudaMalloc(&d_result,N*N*sizeof(double));

	cudaProfilerStart();

	cudaMemcpy(d_a,a,N*N*sizeof(double),cudaMemcpyHostToDevice);

	cudaEventRecord(st,0);

	squareMatrixGpu<<<1,N>>>(d_a,d_result);

	cudaProfilerStop();
//	cudaDeviceSynchronize();

	cudaEventRecord(end);
	cudaEventSynchronize(end);

	cudaEventElapsedTime(&ms,st,end);

	printf("Time taken to multiply on GPU %f ms\n",ms);

	cudaEventRecord(st,0);

	squareMatrixGpuV2<<<N,N>>>(d_a,d_result);

	cudaEventRecord(end);
	cudaEventSynchronize(end);
	cudaEventElapsedTime(&ms,st,end);

	printf("Time taken to multiply on GPU-V2 %f ms\n",ms);

	return 0;
}
