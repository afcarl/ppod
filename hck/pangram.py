#!/usr/bin/env python3

'''
Print lines on stdin that are English pangrams.

Shortest one in PubMed 2012:

    "Venezuelan equine encephalomyelitis: report of an outbreak associated
        with jungle exposure."

From PMID:6438552.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2012-08-25
'''

from string import ascii_letters
from sys import stdin

### Constants
LOWERCASE_LETTERS = set(ascii_letters.lower())
###

def main(args):
    for line in (l.rstrip('\n') for l in stdin):
        if len(set(line.lower()) & LOWERCASE_LETTERS) == len(LOWERCASE_LETTERS):
            print(line)
    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
