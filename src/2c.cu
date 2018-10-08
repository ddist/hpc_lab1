#include <stdio.h>
#include <stdlib.h>	
#include <time.h>
#include <math.h>


#define E 2.71828182845904523536


__global__ void euler_step(float * array, int m, int step) {
	float dt = powf(10,-3);
	int tId = threadIdx.x + blockIdx.x * blockDim.x;
	if (tId < m) {
		array[tId] = array[tId] + dt*(4*(dt*step)-array[tId]+3+tId);
	};
};




int main() {
	cudaEvent_t start, stop;
	int e_s = 100000000;
	int n_i = 1000;
	int block[4] = {64,128,256,512};
	for(int m =0; m < 4;m++){
		float error = 0;
		int block_size = block[m];
		float elapsed=0;
  		int grid_size = (int) ceil((float)e_s / block_size);
		float * resultados = (float *) malloc(e_s * sizeof(float));
		float * d_r;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);

		for(int k = 0; k < e_s; k++){
			resultados[k] = k;
		}
		cudaMalloc(&d_r, e_s * sizeof(float));
		cudaMemcpy(d_r, resultados, e_s * sizeof(float), cudaMemcpyHostToDevice);

		cudaEventRecord(start, 0);
		for(int n = 0; n < n_i; n++){
			euler_step<<<grid_size, block_size>>>(d_r,e_s,n);
		}
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsed, start, stop);
		cudaEventDestroy(start);
		cudaEventDestroy(stop);

		cudaMemcpy(resultados, d_r, e_s  * sizeof(float), cudaMemcpyDeviceToHost);

		for(int g = 0; g < e_s; g++){
			error = error + powf(resultados[g]-((1/E)+4-1+g),2);
		}
		
		printf("Executed with %d blocks\n", block[m]);
		printf("The elapsed time in gpu was %.2f ms \n", elapsed);
		printf("Mean squared error: %f \n", error/e_s);		

		free(resultados);
		cudaFree(d_r);
	}




return 0;

}

