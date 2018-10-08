#include <stdio.h>
#include <stdlib.h>	
#include <time.h>


__global__ void euler_step(float * array, int m, int step) {
	float dt = powf(10,-3);
	int tId = threadIdx.x + blockIdx.x * blockDim.x;
	if (tId < m) {
		array[tId] = array[tId] + dt*(4*(dt*step)-array[tId]+3+tId);
	};
};




int main() {
	cudaEvent_t start, stop;
	int e_s = 1000;
	int n_i = 1000;
	int block_size = 256;
	for(int m =0; m < 5;m++){
		e_s = e_s*10;
		float elapsed=0;
  		int grid_size = (int) ceil((float)e_s / block_size);
		float * resultados = (float *) malloc(e_s * sizeof(float));
		float * d_r;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);

		for(int m = 0; m < e_s; m++){
			resultados[m] = m;
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
		
		printf("Executed with %d equations\n", e_s);
		printf("The elapsed time in gpu was %.2f ms \n", elapsed);
		//printf("%f\n", resultados[0]);

		free(resultados);
		cudaFree(d_r);
	}




return 0;

}
