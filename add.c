#include<stdio.h>
#include<time.h>
#include<immintrin.h>
#include<omp.h>

#define N 1000000

void add_parallel(double* res, double* a, double* b, int size){
	int i;
	#pragma parallel for
	for(i=0;i<size; i++){
		res[i]=a[i]+b[i];
	}
}


void add_seq(double* res, double* a, double* b, int size){
	int i;
	for(i=0;i<size; i++){
		res[i]=a[i]+b[i];
	}
}

void add(double* res, double* a, double* b, int size){
	int i;
	for(i=0;i<size;i+=4){
		const __m256d ka = _mm256_load_pd(&a[i]);
		const __m256d kb = _mm256_load_pd(&b[i]);

		const __m256d kres = _mm256_add_pd(ka, kb);
		_mm256_stream_pd(&res[i], kres);

		//es[i]=a[i]+b[i];
	}
}

int main() {
//	double a[N];
//	double b[N];
	omp_set_num_threads(20);
	double  result[N];

	double *a=(double*)aligned_alloc(1024,N*sizeof(double));
	double *b=(double*)aligned_alloc(1024,N*sizeof(double));

	int i;
	clock_t start,stop;
	
	for(i=0; i<N; i++){
		a[i]=1.0;
		b[i]=1.0;
	}

	start=clock();
	add(result,a,b,N);
	stop=clock();

	printf("TIME TAKEN SEQUENTIAL %lf\n",(double)(stop-start)/CLOCKS_PER_SEC);

	start=clock();
	add_seq(result,a,b,N);
	stop=clock();


	printf("TIME TAKEN VECTORIZED %lf\n",(double)(stop-start)/CLOCKS_PER_SEC);

	start=clock();
	add_parallel(result,a,b,N);
	stop=clock();


	printf("TIME TAKEN BY PARALLEL %lf\n",(double)(stop-start)/CLOCKS_PER_SEC);



	//for(i=0; i<N; i++)
	//	printf("%lf ",result[i]);

	return 0;
}
