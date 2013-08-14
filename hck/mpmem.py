#!/usr/bin/env python

'''
Demonstration of how to use multiprocessing in Python to push out samples of a
    larger data set to multiple workers (Stochastic Gradient Descent anyone?).

Note: If you find the memory behaviour using the --after flag odd, have a look
    at how forking works under *NIX and be careful in the future.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2013-08-14
'''

from __future__ import division
from __future__ import print_function

from argparse import ArgumentParser
from itertools import izip
from multiprocessing import Pool
from os import getpid
from random import randint
from random import sample
from subprocess import PIPE
from subprocess import Popen
from sys import getsizeof
from sys import stderr

### Constants
POOL_SIZE = 3
NUM_BATCHES = POOL_SIZE * 4
INT_SIZE = getsizeof(int())
ONE_MB_IN_BYTES = 1024 ** 2
DEFAULT_DATA_SIZE = 32
###

def _argparser():
    argparser = ArgumentParser('Multiprocessing and memory demonstration')

    argparser.add_argument('-a', '--after', action='store_true',
            help='initalise the worker pool after allocating the data')
    argparser.add_argument('-s', '--data-size', default=DEFAULT_DATA_SIZE,
            type=int, help=('size of data segment to allocate for the main '
                'process (default {}MB)').format(DEFAULT_DATA_SIZE))

    return argparser

# Almost the most naive prime checking function possible (we want it to be
#   resonably slow).
def is_prime(x):
    if x % 2 == 0:
        return False

    for i in xrange(1, x // 2, 2):
        if x % i == 0:
            return False

    return True

def memory_allocated():
    ps = Popen(('ps', 'u', '-p', str(getpid()), ), stdout=PIPE)
    ps.wait()
    return int(ps.stdout.readlines()[1].split()[5])

def _process(args):
    batch_id, data = args

    pid = getpid()
    mem = memory_allocated()

    results = tuple((is_prime(i) for i in data))

    return (pid, mem, batch_id, results, )

def main(args):
    argp = _argparser().parse_args(args[1:])

    if not argp.after:
        pool = Pool(POOL_SIZE)

    # Create some random numbers to work with.
    num_ints = (ONE_MB_IN_BYTES // INT_SIZE) * argp.data_size
    print('Allocating', num_ints, ('({}MB) random integers...'
        ).format(argp.data_size), end=' ', file=stderr)
    data = tuple((randint(2, 2 ** 32) for _ in xrange(num_ints)))
    print('Done!', file=stderr)

    if argp.after:
        pool = Pool(POOL_SIZE)

    # Segment the random numbers into work batches.
    batch_size = len(data) // 100
    batches = tuple(((i, sample(data, batch_size), )
        for i in xrange(NUM_BATCHES)))

    print('Main process ({}), memory allocated:'.format(getpid()),
            memory_allocated(), file=stderr)

    # Process the batches and report back the memory usage for each worker.
    for pid, mem, batch_id, results in pool.imap_unordered(_process, batches):
        print('Worker process ({}), memory allocated:'.format(pid), mem,
                file=stderr)

        # Just to make sure, verify that each piece of work was accurate.
        gold = tuple(is_prime(i) for i in batches[batch_id][1])
        assert not any((res != gold for res, gold in izip(results, gold)))

    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
