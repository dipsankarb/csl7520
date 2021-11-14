#include<stdio.h>

__global__ void dkernel(unsigned int *x){
	++x[0]; // LEAD TO 1
	//atomicInc(&x[0],1000); // LEAD TO 2
}

int main() {
	int hx[]={0,0,0,0,0,0,0,0,0,0};
	unsigned int *x;
	cudaMalloc(&x,sizeof(unsigned int)*10);
	cudaMemcpy(x,hx,10*sizeof(unsigned int),cudaMemcpyHostToDevice);
	
	dkernel<<<1,200>>>(x);
	
	cudaDeviceSynchronize();
	cudaMemcpy(hx,x,10*sizeof(unsigned int),cudaMemcpyDeviceToHost);

	printf("x[0] is %d\n",hx[0]);

	return 0;
}
