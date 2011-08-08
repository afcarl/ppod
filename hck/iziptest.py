#!/usr/bin/env python

'''
Ought to put an end to any argument that zip is a bad idea for large lists.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2011-08-08
'''

from itertools import izip
from math import fsum
from timeit import repeat

### Constants
# Two fairly large lists
A_LIST = range(2**20)
B_LIST = range(2**20)
###

def zip_test():
    for a, b in zip(A_LIST, B_LIST):
        pass

def izip_test():
    for a, b in izip(A_LIST, B_LIST):
        pass

# Discounted mean
def disc_mean(v, disc=0.1):
    v.sort()
    offset = int(len(v) * 0.1)
    return fsum(v[offset:-offset]) / float(len(v))

def _repeat(stmt):
    return repeat(stmt, repeat=10, number=10)

print 'Testing zip...',
zip_res = _repeat('from __main__ import zip_test; zip_test()')
print 'Done!'
print 'Discounted mean (10%%): %s' % disc_mean(zip_res)

print 'Testing izip...',
izip_res = _repeat('from __main__ import izip_test; izip_test()')
print 'Done!'
print 'Discounted mean (10%%): %s' % disc_mean(izip_res)
