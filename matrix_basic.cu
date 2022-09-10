#include <stdio.h>
#define N 128
#define M 10
#define in(i,j) ((i*N)+j)

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
			printf("IN HERE\n");
		}
	}
	
}

void squareCPU(int *m, int *res){

	int i,j,k;

	for(i=0;i<N;i++){
		for(j=0;j<N;j++){
			for(k=0;k<N;k++){
				res[in(i,j)] += m[in(i,k)]*m[in(k,j)];
			}
		}
	}

}
int main(){

	int *m, *d_m, *res, i,j;
	clock_t start, stop;
	float ms;

	cudaEvent_t s,p;

	cudaEventCreate(&s);
	cudaEventCreate(&p);

	m=(int*)malloc(N*N*sizeof(int));
	res=(int*)malloc(N*N*sizeof(int));
	cudaMalloc(&d_m,sizeof(int)*N*N);

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

	squareGPUv1<<<1,N>>>(m,res);

	cudaEventRecord(p);
	cudaEventSynchronize(p);

	cudaEventElapsedTime(&ms,s,p);
	printf("Time taken on GPU v1 kernel is %f\n",ms);

	return 0;
}
