#include <time.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#define E 2.71828182845904523536

// Sequential Euler Method for CPU
float* euler_cpu(float y0, float dt, int n) {
    // Allocate memory for the solution array
    float* y = malloc(sizeof(float) * n);
    // Initial condition
    y[0] = y0;
    
    for(size_t i = 1; i < n; i++)
    {
        y[i] = y[i-1] + dt*powf(E, -dt*i);
    }
    return y;
}

int main(int argc, char const *argv[])
{
    clock_t t1, t2;
    // Problem fixed parameters
    float dts[6] = {0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001};
    float y0 = -1.0;
    
    for(size_t i = 0; i < 6; i++)
    {
        printf("Sequential Euler for dt = %f\n", dts[i]);
        int n = (int)(10/dts[i]);
        // Clock the euler method
        t1 = clock();
        float* y = euler_cpu(y0, dts[i], n);
        t2 = clock();
        // Print results
        printf("Execution time : %f [ms]\n", 1000.0 * (double)(t2 - t1) / CLOCKS_PER_SEC);
        float y_true;
        float mse = 0.0;

        for (size_t j = 0; j < n; j++)
        {
            y_true = -powf(E, -dts[i]*j);
            mse += powf(y_true - y[j], 2.0);
        }
        mse = mse/n;
        
        printf("Real value : %f ; Euler value : %f MSE : %.12f\n\n", y_true, y[n-1], mse);
        // Free memory allocated in euler_cpu()
        free(y);
    }

    return 0;
}
