#!/usr/bin/env python

'''
Split the MUC-3/4 corpus into manageable pieces.

http://www-nlpir.nist.gov/related_projects/muc/muc_data/muc_data_index.html

ls dev-muc3-*-* tst*-* | ./mucsplit.py

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2011-06-27
'''

from sys import stderr, stdin
from re import compile as re_compile

### Constants
# Matches MUC-4 document identifiers
DOC_ID_REGEX = re_compile(r'(^[A-Za-z0-9]+\-[A-Za-z0-9]+-[A-Za-z0-9]+)(:?\ \([^)]+\))?$')
###

def main(args):
    for filepath in (l.rstrip('\n') for l in stdin):
        curr_file = None
        try:
            with open(filepath, 'r') as muc_file:
                for line_number, line in enumerate(muc_file, start=1):
                    m = DOC_ID_REGEX.match(line)
                    if m is not None:
                        if curr_file is not None:
                            curr_file.close()

                        curr_file = open(m.group(1).lower() + '.txt', 'w')
                        curr_file.write(line)
                    else:
                        if curr_file is None:
                            print >> stderr, ('WARNING: found data before '
                                    'document id in {} #{}'
                                    ).format(filepath, line_number)
                        else:
                            curr_file.write(line)
        except:
            if curr_file is not None:
                curr_file.close()
            raise

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
