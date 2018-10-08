#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define E 2.71828182845904523536


__global__ void euler_gpu(float * array, float y0, float dt, int n){
    // Initial condition
    int tId = threadIdx.x + blockIdx.x * blockDim.x;
    if (tId < n) {
    	float initial_value = y0; 
	    for(size_t i = 1; i < tId; i++){
	        initial_value = initial_value + dt*powf(E, -dt*i);
	    };
	    array[tId] = initial_value;

	};
};



int main(int argc, char const *argv[]){
	cudaEvent_t start, stop;
	float dts[6] = {0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001};
    float y0 = -1.0;
    int block_size = 256;

    for(size_t i = 0; i < 6; i++){
    	int n = (int)(10/dts[i]);
    	float elapsed=0;
    	double error = 0;

    	float * resultados = (float *) malloc(n * sizeof(float));
    	float * d_r;

    	int grid_size = (int) ceil((float)n / block_size);

    	cudaEventCreate(&start);
		cudaEventCreate(&stop);

		cudaMalloc(&d_r, n * sizeof(float));
		cudaMemcpy(d_r, resultados, n * sizeof(float), cudaMemcpyHostToDevice);
		cudaEventRecord(start, 0);
		euler_gpu<<<grid_size, block_size>>>(d_r, y0, dts[i], n);
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsed, start, stop);
		cudaEventDestroy(start);
		cudaEventDestroy(stop);

		cudaMemcpy(resultados, d_r, n  * sizeof(float), cudaMemcpyDeviceToHost);
		for(int g = 0; g < n; g++){
			float real =  -powf(E, -dts[i]*g);
			error = error + powf((resultados[g]-real),2);
		}

		printf("Executed with %f dt\n", dts[i]);
		printf("The elapsed time in gpu was %.2f ms \n", elapsed);
		printf("Mean squared error: %.16f \n", error/n);		

		free(resultados);
		cudaFree(d_r);
    }
    return 0;
};



