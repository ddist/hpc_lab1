#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define E 2.71828182845904523536

void euler_step(float * array, int m, int step){
    float dt = pow(10,-3);
    for(int j =0; j<m; j++){
            array[j] = array[j] + dt*(4*(dt*step)-array[j]+3+j);
    };
};

int main(int argc, char *argv[]){
    clock_t t1, t2;
    int e_s = 1000;
    int n_i = 1000;
    for(int m =0; m < 5;m++){
        e_s = e_s*10;
        float error = 0;
        float * resultados = malloc(e_s * sizeof(float));
        //Se inicializa el array
        for(int m = 0; m < e_s; m++){
                resultados[m] = m;
        }
        t1 = clock();
        for(int n = 0; n < n_i; n++){
                euler_step(resultados,e_s,n);
        }
        t2 = clock();
        for(int n = 0; n < e_s; n++){
                error = error + powf((resultados[n]-((1/E)+4-1+n)),2);
        };
        printf("Executed with %d equations\n", e_s);
        printf("Execution time = %f [ms]\n", 1000.0 * (double)(t2 - t1) / CLOCKS_PER_SEC);
        printf("MSE = %f\n",error/e_s);

        free(resultados);
    }
	return 0;
}