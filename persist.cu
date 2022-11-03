#include<stdio.h>

__global__ void printk(int *counter){

	do{	
		while(*counter % 2 == 0)
			printf("GPU COUNTER IS %d\n",*counter);
		++*counter;
	}while(*counter<1000000);
}

int main(){
	int hcounter=0,*counter;

//	cudaMalloc(&counter, sizeof(int));

	cudaHostAlloc(&counter,sizeof(int),0);

	printk<<<1,1>>>(counter);

	do{
		while(*counter % 2 == 1)
			printf("CPU COUNTER IS %d \n",*counter);
//		cudaMemcpy(counter,&hcounter,sizeof(int),cudaMemcpyHostToDevice);
	//	cudaDeviceSynchronize();
//		cudaMemcpy(&hcounter,counter,sizeof(int),cudaMemcpyDeviceToHost);

	}while(++*counter<10);
	return 0;
}
