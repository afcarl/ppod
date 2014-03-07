# Recursive Neural Network (RNN) Performance #

Performance tests for a [Recursive Network Network][rnn] (RNN) forward and
backward passes for a set of language I can consider working in.
We perform one million forward and backward passes using a single thread of
execution and calculate the total time consumption.
Minor optimations are made on a language-by-language basis.
This metric gives us some fairly okay ballpark numbers.
All tests were performed on a laptop with a
Intel(R) Core(TM)2 Duo CPU P8600 @ 2.40GHz CPU and Lubuntu 13.10.

Language    | Timing (lower is better)
----------- | ------------------------
C           | 8.19
C (BLAS)    | 6.00
Cython 2.x  | 8.75
Cython 3.x  | 8.83
Julia       | 17.85
Matlab      | 17.04
Octave      | 26.95
Python 2.x  | 28.44
Python 3.x  | 30.98

[rnn]: http://www.socher.org/uploads/Main/2010SocherManningNg.pdf
