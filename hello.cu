
#include <stdio.h>

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

__global__ void function(){

	printf("Hello World! from Thread %d \n", threadIdx.x);
}

int main(){

	function<<<1,1025>>>(); // first two parameters in kernel calls are the thread configurations

	gpuErrchk( cudaPeekAtLastError() );

	cudaDeviceSynchronize();

	return 0;
}
