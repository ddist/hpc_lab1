#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define E 2.71828182845904523536

__global__ void euler_gpu_2(float * array, float * suma, float dt, int n){
	int tId = threadIdx.x + blockIdx.x * blockDim.x;
	if (tId < n) {
		array[tId] = -1 + dt*suma[tId];
	};
};

int main(int argc, char const *argv[]){
	cudaEvent_t start, stop;
	clock_t t1, t2;
	float dts[6] = {0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001};
    int block_size = 256;
    for(size_t i = 0; i < 6; i++){
    	int n = (int)(10/dts[i]);
    	int grid_size = (int) ceil((float)n / block_size);
    	float elapsed=0;
    	double cpu_time = 0;
    	double error = 0;
    	float * resultados = (float *) malloc(n * sizeof(float));
    	float * sumatoria = (float *) malloc(n * sizeof(float));
    	float * d_r;
    	float * d_s;
    	sumatoria[0] = 1;
    	t1 = clock(); 
    	for(int j =1; j < n; j++){
    		sumatoria[j] = powf(E, -dts[i]*j) + sumatoria[j-1];
    	}
    	t2 = clock();
    	cudaEventCreate(&start);
		cudaEventCreate(&stop);
		cudaEventRecord(start, 0);

		cudaMalloc(&d_r, n * sizeof(float));
		cudaMalloc(&d_s, n * sizeof(float));
		cudaMemcpy(d_r, resultados, n * sizeof(float), cudaMemcpyHostToDevice);
		cudaMemcpy(d_s, sumatoria, n * sizeof(float), cudaMemcpyHostToDevice);
		euler_gpu_2<<<grid_size, block_size>>>(d_r,d_s, dts[i], n);
		cudaMemcpy(resultados, d_r, n  * sizeof(float), cudaMemcpyDeviceToHost);
		cudaMemcpy(sumatoria, d_s, n  * sizeof(float), cudaMemcpyDeviceToHost);
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsed, start, stop);
		cudaEventDestroy(start);
		cudaEventDestroy(stop);

		for(int g = 0; g < n; g++){
			float real =  -powf(E, -dts[i]*g);
			error = error + powf((resultados[g]-real),2);
		}
		cpu_time = 1000.0 * (double)(t2 - t1) / CLOCKS_PER_SEC;
		printf("Executed with %f dt\n", dts[i]);
		printf("Mean squared error: %.16f \n", error/n);
		printf("The elapsed time in gpu was %.2f ms \n", elapsed);
		printf("The elapsed time in cpu was %.2f ms \n", cpu_time);
		printf("The total time was %.2f ms \n", elapsed + cpu_time);
	}

	return 0;

}

