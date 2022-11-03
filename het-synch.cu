#include<stdio.h>

__global__ void printk(int *counter){

	++*counter;
	printf("GPU COUNTER IS %d\n",*counter);
}

int main(){
	int hcounter=0,*counter;

//	cudaMalloc(&counter, sizeof(int));

	cudaHostAlloc(&counter,sizeof(int),0);

	do{
		printf("CPU COUNTER IS %d \n",*counter);
//		cudaMemcpy(counter,&hcounter,sizeof(int),cudaMemcpyHostToDevice);
		printk<<<1,1>>>(counter);
		cudaDeviceSynchronize();
//		cudaMemcpy(&hcounter,counter,sizeof(int),cudaMemcpyDeviceToHost);

	}while(++*counter<10);
	return 0;
}
