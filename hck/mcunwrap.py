#!/usr/bin/env python

'''
XXX

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2012-01-26
'''

# TODO: Support a few more quirks to the output, blank lines etc.
# TODO: Proper testing!

from argparse import ArgumentParser, FileType
from sys import stdin, stderr

### Constants
# TODO: Doc
# TODO: Control file suffix
ARGPARSER = ArgumentParser()#XXX:
ARGPARSER.add_argument('wrap_info', type=FileType('r')) # Communication
# TODO: Write-able Directory Type! 'r' or 'w'
ARGPARSER.add_argument('output') # File for wrap, dir for unwrap
ARGPARSER.add_argument('-i', '--input', type=FileType('r'), default=stdin)
ARGPARSER.add_argument('-d', '--debug', action='store_true')
###

def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    for wrap_info in (l.rstrip('\n') for l in argp.wrap_info):
        txt_file_path, lines, blank_lines_idx, checksum = wrap_info.split('\t')
        lines = int(lines)
        if blank_lines_idx:
            blank_lines = set(int(i) for i in blank_lines_idx.split(','))
        else:
            blank_lines = set()
        
        output_path = txt_file_path + '.ptb'
        if argp.debug:
            print >> stderr, 'Unwrapping:', txt_file_path, 'to', output_path

        # TODO: Checksum!
        # TODO: Non-default extension!
        blanks_written = 0
        lines_written = 0
        with open(output_path, 'w') as output_file:
            for line_num in xrange(1, lines + 1):
                if line_num in blank_lines:
                    output_file.write('\n')
                    blanks_written += 1
                    #print >> stderr, '%s:' % txt_file_path
                else:
                    output_file.write(argp.input.readline())
                    lines_written += 1
                    #print >> stderr, '%s:' % txt_file_path, argp.input.readline(),

        if argp.debug:
            print >> stderr, ('Read {} non-blank lines and wrote {} lines'
                    ).format(blanks_written, lines_written)
            #        ).format(lines - len(blank_lines), line_num)

    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
