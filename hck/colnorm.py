#!/usr/bin/env python

'''
Normalise each column in a tsv-file.

Author:     Pontus Stenetorp <pontus stenetorp se>
Version:    2012-12-05
'''

from argparse import ArgumentParser, FileType
from sys import stdin, stdout

def _argparser():
    argparser = ArgumentParser('Normalise a tsv-file column-wise (in-memory)')
    argparser.add_argument('-i', '--input', type=FileType('r'), default=stdin)
    return argparser

def main(args):
    argp = _argparser().parse_args(args[1:])
    
    max_by_idx = {}
    col_dats = []
    for line in (l.rstrip('\n') for l in argp.input):
        col_dat = []
        for col_idx, col_val_str in enumerate(line.split('\t')):
            col_val = float(col_val_str)
            col_dat.append(col_val)

            try:
                max_by_idx[col_idx] = max(col_val, max_by_idx[col_idx])
            except KeyError:
                max_by_idx[col_idx] = col_val

        col_dats.append(col_dat)

    for col_dat in col_dats:
        stdout.write('\t'.join(str(col_val / max_by_idx[col_idx])
            for col_idx, col_val in enumerate(col_dat)))
        stdout.write('\n')

    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
