#include<stdio.h>
#include<sys/time.h>

__device__ int k2, preprocess, work;

__global__ void kinit(){
	k2=0;
	preprocess=0;
}

__device__ void process(){
	int a[10]={0};
	for(int i=0;i<10;i++)
		a[i%2]++;
}

__global__ void firstkernel(int *work){
	process();
	__syncthreads;

	preprocess=1;
	*work=100;
	if(k2){
		*work /= 2;
	}
}

__global__ void secondkernel(int *work){
	if(preprocess)
		;
	else{
		k2=1;
		*work=100/2;
	}
}


int main(){
	srand(time(NULL));
	cudaStream_t s1, s2;
	cudaStreamCreate(&s1);
	cudaStreamCreate(&s2);

	int *work;
	cudaMalloc((int**)&work,sizeof(int));
	
	for(int i=0;i<10;i++){
		kinit<<<1,1>>>();
		cudaDeviceSynchronize();

		firstkernel<<<1,64,0,s1>>>(work);
		cudaDeviceSynchronize();

		if(rand() % 2){
			secondkernel<<<1,64,0,s2>>>(work);
			printf("Two kernels working \n");
		}
		else
			printf("One kernel working\n");

		cudaDeviceSynchronize();

		int h;
		cudaMemcpy(&h, (int*)work, sizeof(int),cudaMemcpyDeviceToHost);
		printf("Work is %d\n",h);
	}



	return 0;
}
