#!/usr/bin/env python

'''
Wrapping of any PennTreeBank (PTB) parser to turn multiple files into a single
    file or stream. Then unwrap the output into the separate files again.

Usage:

    ls *.txt.tok \
            | ./mcwrap.py -d fifo \
            | ${PTB_CALL} \
            | ./mcunwrap.py -d fifo output_dir

Note: Name is a pun intended, McClosky model for Charniak-Johnson (mc) and a
    wrapping script (wrap).

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2012-01-26
'''

#TODO: Clean-up

from argparse import ArgumentParser, FileType
from sys import stdout, stderr, stdin

### Constants
# TODO: HELP!
ARGPARSER = ArgumentParser()#XXX:
ARGPARSER.add_argument('wrap_info_path', type=FileType('w'))
ARGPARSER.add_argument('-i', '--txt_file_paths', type=FileType('r'),
        default=stdin)
ARGPARSER.add_argument('-o', '--txt_output', type=FileType('w'),
        default=stdout)
ARGPARSER.add_argument('-d', '--debug', action='store_true')
###

# TODO: CHECKSUM TYPES, IGNORE WS ETC.!

def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    for txt_file_path in (l.rstrip('\n') for l in argp.txt_file_paths):
        if argp.debug:
            print >> stderr, 'Wrapping:', txt_file_path

        blank_lines = []
        with open(txt_file_path, 'r') as txt_file:
            for line_num, line in enumerate(txt_file, start=1):
                if not line.rstrip('\n'):
                    blank_lines.append(line_num)
                else:
                    # XXX: Control by flag if you want to print or not...
                    argp.txt_output.write(line)

        blank_lines_str = ','.join(str(i) for i in blank_lines)
        if argp.debug:
            print >> stderr, ('File stats: {} lines, blanks: {}'
                    ).format(line_num, blank_lines_str)
        #XXX: Also need the indices for the blank lines...
        argp.wrap_info_path.write('{}\t{}\t{}\t{}\n'.format(txt_file_path, line_num,
            # TODO: CHECKSUM!
            blank_lines_str, '-'))

    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
