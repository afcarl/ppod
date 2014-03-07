# vim:set ft=cython ts=4 sw=4 sts=4 autoindent:

#!python
# cython: boundscheck=False

from __future__ import print_function

from time import time

from numpy import empty
from numpy import float64

from libc.math cimport pow
from libc.math cimport tanh
from libc.stdlib cimport free
from libc.stdlib cimport malloc
from numpy cimport PyArray_DATA
from numpy cimport float64_t

DOUBLE = float64
ctypedef float64_t DOUBLE_t

cdef extern from 'cblas.h':
    enum CBLAS_ORDER: CblasRowMajor, CblasColMajor
    enum CBLAS_TRANSPOSE: CblasNoTrans, CblasTrans, CblasConjTrans

    void cblas_dgemv 'cblas_dgemv'(CBLAS_ORDER order,
            CBLAS_TRANSPOSE TransA, int M, int N,
            double alpha, double *A, int lda,
            double *X, int incX, double beta,
            double *Y, int incY)
    void cblas_dgemm 'cblas_dgemm'(CBLAS_ORDER Order, CBLAS_TRANSPOSE TransA,
            CBLAS_TRANSPOSE TransB, int M, int N, int K, double alpha,
            double *A, int lda, double *B, int ldb, double beta, double *C,
            int ldc)

cdef int IN, OUT

DEBUG = False
if not DEBUG:
    IN = 64
    OUT = 32
    NUM_ITS = 10 ** 6
else:
    IN = 4
    OUT = 2
    NUM_ITS = 1
INIT_VAL = 0.4711

cdef void forward(const int rows, const int cols, const DOUBLE_t *W_ptr,
        const DOUBLE_t *x_ptr, DOUBLE_t *a_ptr):
    cdef int row

    cblas_dgemv(CblasColMajor, CblasNoTrans, rows, cols, 1.0, W_ptr, rows,
            x_ptr, 1, 0.0, a_ptr, 1)
    for row in range(rows):
        a_ptr[row] = tanh(a_ptr[row])

cdef void backward(const int rows, const int cols, const DOUBLE_t *x_ptr,
        DOUBLE_t *a_ptr, DOUBLE_t *d_ptr, DOUBLE_t *b_ptr):
    cdef int row
    cdef DOUBLE_t *tmp_ptr

    tmp_ptr = <DOUBLE_t *> malloc(rows * sizeof(DOUBLE_t))
    for row in range(rows):
        tmp_ptr[row] = (1.0 - pow(a_ptr[row], 2)) * d_ptr[row]
    cblas_dgemm(CblasColMajor, CblasTrans, CblasNoTrans, rows, cols, 1, 1.0,
            tmp_ptr, 1, x_ptr, 1, 0.0, b_ptr, rows)

    free(tmp_ptr)

W = empty((OUT, IN))
W[:] = INIT_VAL
x = empty((IN, 1))
x[:] = INIT_VAL
d = empty((OUT, 1))
d[:] = INIT_VAL

a = empty((OUT, 1))
b = empty((OUT, IN))

cdef DOUBLE_t *W_ptr = <DOUBLE_t *> PyArray_DATA(W)
cdef DOUBLE_t *x_ptr = <DOUBLE_t *> PyArray_DATA(x)
cdef DOUBLE_t *d_ptr = <DOUBLE_t *> PyArray_DATA(d)

cdef DOUBLE_t *a_ptr = <DOUBLE_t *> PyArray_DATA(a)
cdef DOUBLE_t *b_ptr = <DOUBLE_t *> PyArray_DATA(b)

tic = time()
for _ in range(NUM_ITS):
    forward(OUT, IN, W_ptr, x_ptr, a_ptr)
    backward(OUT, IN, x_ptr, a_ptr, d_ptr, b_ptr)
toc = time()

if DEBUG:
    print(' '.join(str(e) for e in a.flat))
    for u in b:
        print(' '.join(str(v) for v in u.flat))
print(toc - tic)
