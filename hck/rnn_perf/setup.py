#!/usr/bin/env python3
# vim:set ft=python ts=4 sw=4 sts=4 autoindent:

from Cython.Build import cythonize
from distutils.core import Extension
from distutils.core import setup

extensions = [
        Extension('rnn_perf', ['rnn_perf.pyx', ],
            libraries=[
                'blas',
                ],
            ),
        ]

setup(
    ext_modules=cythonize(extensions),
)
