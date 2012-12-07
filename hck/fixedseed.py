#!/usr/bin/env python

'''
Perform operations with a fixed seed for a block, then restore the state of
the PRNG. All using the with syntax.

    with FixedSeed(4711):
        ...

Has this already been done? It is quite handy for experiments since it makes
sure that you don't forget to restore the state.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2011-08-24
'''

class FixedSeed(object):
    def __init__(self, _seed, numpy=False):
        self.seed = _seed
        self.state = None
        if not numpy:
            from random import getstate, seed, setstate
            self.__seed = seed
            self.__getstate = getstate
            self.__setstate = setstate
        else:
            from numpy.random import get_state, seed, set_state
            self.__seed = seed
            self.__getstate = get_state
            self.__setstate = set_state

    def __enter__(self):
        self.state = self.__getstate()
        self.__seed(self.seed)
        return self
    
    def __exit__(self, type, value, traceback):
        self.__setstate(self.state)

# Minor test code
if __name__ == '__main__':
    from sys import stderr

    def _test(numpy=False):
        if not numpy:
            from random import random
        else:
            from numpy.random import random

        with FixedSeed(4711, numpy=numpy):
            a = [random() for _ in xrange(17)]
        after_a = random()

        with FixedSeed(4711, numpy=numpy):
            b = [random() for _ in xrange(17)]
        after_b = random()

        assert a == b
        # Should fail in most cases
        assert after_a != after_b

    # Test the standard Python implementation
    _test()

    # Test the numpy implementation
    try:
        _test(numpy=True)
    except ImportError:
        print >> stderr, "WARNING: numpy import failure, skipping numpy tests"
