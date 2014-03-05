#!/usr/bin/env python3

from __future__ import print_function

from time import time

from numpy import dot
from numpy import tanh
from numpy import empty

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

def forward(W, x):
    return tanh(dot(W, x))

def tanh_prime(x):
    return 1 - x ** 2

def backward(x, a, m):
    return dot((tanh_prime(a) * m), x.T)

W = empty((OUT, IN))
W[:] = INIT_VAL
x = empty((IN, 1))
x[:] = INIT_VAL
m = empty((OUT, 1))
m[:] = INIT_VAL

tic = time()
for _ in range(NUM_ITS):
    a = forward(W, x)
    b = backward(x, a, m)
toc = time()

if DEBUG:
    print(' '.join(str(e) for e in a.flat))
    for u in b:
        print(' '.join(str(v) for v in u.flat))
print(toc - tic)
