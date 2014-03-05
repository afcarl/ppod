#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

//#define DEBUG
#ifndef DEBUG
#define IN 64
#define OUT 32
#define NUM_ITS 1000000
#else
#define IN 4
#define OUT 2
#define NUM_ITS 1
#endif
#define INIT_VAL 0.4711

#ifdef USE_BLAS
#include <cblas.h>
#endif

double *
mtrx(int rows, int cols) {
    int row, col;
    double *d, *it;
    d = (double *) malloc(rows * cols * sizeof(double));
    it = d;
    for (row = 0; row < rows; row++) {
        for (col = 0; col < cols; col++) {
            // Not very random, but makes debugging easier.
            *it = INIT_VAL;
            it++;
        }
    }
    return d;
}

void
forward(const int rows, const int cols, double *W, double *x,
        double *a) {
    #ifndef USE_BLAS
    int row, col;
    double *W_it, *x_it, *a_it;

    W_it = W;
    a_it = a;
    for (row = 0; row < rows; row++) {
        *a_it = 0.0;
        x_it = x;
        for (col = 0; col < cols; col++) {
            *a_it += *W_it * *x_it;
            W_it++;
            x_it++;
        }
        *a_it = tanh(*a_it);
        a_it++;
    }
    #else /* USE_BLAS */
    int row;

    cblas_dgemv(CblasColMajor, CblasNoTrans, rows, cols, 1.0, W, rows, x, 1,
            0.0, a, 1);
    for (row = 0; row < rows; row++) {
        a[row] = tanh(a[row]);
    }
    #endif /* USE_BLAS */
}

void
backward(const int rows, const int cols, double *x, double *a, double *d,
        double *b) {
    #ifndef USE_BLAS
    int row, col;
    double ad;
    double *x_it, *a_it, *d_it, *b_it;

    a_it = a;
    d_it = d;
    b_it = b;
    for (row = 0; row < rows; row++) {
        ad = (1.0 - pow(*a_it, 2)) * *d_it;

        x_it = x;
        for (col = 0; col < cols; col++) {
            *b_it = ad * *x_it;
            b_it++;
            x_it++;
        }
        a_it++;
        d_it++;
    }
    #else /* USE_BLAS */
    int row;
    double *tmp;

    tmp = (double *) malloc(rows * sizeof(double));
    for (row = 0; row < rows; row++) {
        tmp[row] = (1.0 - pow(a[row], 2)) * d[row];
    }
    cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans, rows, cols, 1, 1.0,
            tmp, 1, x, 1, 0.0, b, rows);

    free(tmp);
    #endif /* USE_BLAS */
}

int
main() {
    int i;
    double *W, *x, *d, *a, *b;
    struct timespec tic, toc;

    W = mtrx(OUT, IN);
    x = mtrx(IN, 1);
    d = mtrx(OUT, 1);
    a = malloc(OUT * sizeof(double));
    b = malloc(OUT * IN * sizeof(double));

    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tic);
    for (i = 0; i < NUM_ITS; i++) {
        forward(OUT, IN, W, x, a);
        backward(OUT, IN, x, a, d, b);
    }
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &toc);

    #ifdef DEBUG
    for (int j = 0; j < OUT; j++) {
        printf("%f ", a[j]);
    }
    printf("\n");

    double *b_it = b;
    for (int u = 0; u < OUT; u++) {
        for (int v = 0; v < IN; v++) {
            printf("%f ", *b_it);
            b_it++;
        }
        printf("\n");
    }
    #endif

    printf("%f\n", (toc.tv_nsec - tic.tv_nsec) / 100000000.0);

    free(b);
    free(a);
    free(d);
    free(x);
    free(W);

    return EXIT_SUCCESS;
}
