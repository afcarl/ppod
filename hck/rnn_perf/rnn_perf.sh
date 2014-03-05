#!/bin/sh

# A set of relevant performance tests for tools I can consider working with.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2014-03-05

CC=gcc
CFLAGS='-O2 -Wall -Wextra -std=gnu11'
echo 'C:' `${CC} ${CFLAGS} -o rnn_perf rnn_perf.c -lm && ./rnn_perf \
    && rm -f ./rnn_perf`
echo 'C (BLAS):' `${CC} ${CFLAGS} -D USE_BLAS -o rnn_perf rnn_perf.c \
    -lm -lblas && ./rnn_perf && rm -f ./rnn_perf`
# TODO: Java?
echo 'Julia:' `./rnn_perf.jl`
# Matlab/Octave are "special", so work around it.
echo 'Matlab:' `matlab -r rnn_perf -nodisplay | grep '^Elapsed' \
    | cut -d ' ' -f 4`
echo 'Octave:' `octave rnn_perf.m | grep '^Elapsed' | cut -d ' ' -f 4`
echo 'Python 2.x:' `python2 rnn_perf.py`
echo 'Python 3.x:' `./rnn_perf.py`
# TODO: Scala?
