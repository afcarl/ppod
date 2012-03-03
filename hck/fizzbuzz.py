#!/usr/bin/env python

'''
Test implementation of a simple FizzBuzz game.

Took about 3m.

Author: Pontus Stenetorp
Version: 2010-12-12
'''

import argparse

### Constants
ARGPARSE = argparse.ArgumentParser(description='A game with Fizz and Buzz!')
ARGPARSE.add_argument('limit', type=int)
###

def main(args):
    argp = ARGPARSE.parse_args(args[1:])

    for i in xrange(1, argp.limit + 1):
        if i % 3 == 0:
            print 'Fizz!'
        elif i % 5 == 0:
            print 'Buzz!'
        else:
            print i

    return 0

if __name__ == '__main__':
    import sys
    exit(main(sys.argv))
