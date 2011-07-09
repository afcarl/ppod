#!/usr/bin/env python

'''
Sanity checking between Penn Tree Bank (PTB) format to ConLL-X and Stanford
Dependency parses for debugging conversion scripts.

Author:     Pontus Stenetorp <pontus stenetorp se>
Version:    2011-01-08
'''

from sys import stderr, stdin
from re import compile as _compile
from argparse import ArgumentParser
from itertools import izip_longest, tee, chain

#TODO: Read stdin or arguments, stdin with a suffix addition
#TODO: Lehvenstein tolerance, warn if within
#TODO: No-warn
#TODO: Print filename if mismatch flag

### Constants
ARGPARSER = ArgumentParser(description=('reads paths to PTB files on stdin '
        'adds a suffix to the path and compares the resulting files '
        'for consistency'))
ARGPARSER.add_argument('dep_format', choices=['conll', 'sd'],
        help='format of the output to sanity check')
# It is a bit dirty to assume suffixing, but it makes thing a little easier
ARGPARSER.add_argument('--dep_suffix', default=None, help=('suffix to add to '
    'the input file path to get the path to the resulting dependency file '
    '(default: dep_format value)'))

PTB_TOK_REGEX = _compile(r'\([^(]+?\ ([^(]+?)\)')
PTB_ESCAPE_MAP = { 
        '-LRB-': '(',
        '-RRB-': ')',
        '-LSB-': '[',
        '-RSB-': ']',
        '-LCB-': '{',
        '-RCB-': '}',
        #Apparently at least the CoNLL converter don't want this done
        #'``': '"',
        }
###

#XXX: We preserve espaces inside tokens, for, well, others do it
def _ptb_unescape(tok):
    if tok in PTB_ESCAPE_MAP:
        return PTB_ESCAPE_MAP[tok]
    else:
        return tok

def _conllx_sent_gen(dep_file_enum):
    for line_num, line in dep_file_enum:
        if not line:
            raise StopIteration

        yield line_num, line.split()[1]
    raise StopIteration

def _sd_sent_gen(dep_file_enum):
    toks = []
    for line_num, line in dep_file_enum:
        if not line:
            break

        for token, index  in (d.rsplit('-', 1)
                for d in line[line.find('(') + 1:line.rfind(')')].split(', ')):
            toks.append((int(index.rstrip("'")), line_num, _ptb_unescape(token)))
    toks.sort()
    last_index = 0
    for index, line_num, token in toks:
        # There are repetitions among the seen token, make sure we skip them
        if index == last_index:
            continue
        # SD has a nasty format that leaves out "irrelevant" tokens
        # We thus return None as a wildcard for missing tokens and have to
        # accept that we can't do a perfect sanity check.
        for skipped_index in xrange(last_index + 1, index):
            yield (None, None)
        last_index = index
        yield (line_num, token)
    raise StopIteration

# It is horrible to do return -1, but a quick hack is a quick hack
def _sanity(ptb_file_path, dep_file_path, sent_gen_func, ignore_fewer=False):
    with open(ptb_file_path) as ptb_file, open(dep_file_path) as dep_file:
        dep_file_enum = enumerate((l.strip() for l in dep_file))
        for ptb_line_num, ptb_line in enumerate(
                (l.strip() for l in ptb_file)):
            ptb_tok_it = (_ptb_unescape(m.group(1))
                    for m in PTB_TOK_REGEX.finditer(ptb_line))
            #TODO: Decide which by flag
            dep_tup_it = sent_gen_func(dep_file_enum)
            
            for ptb_tok, dep_tup in izip_longest(
                    ptb_tok_it, dep_tup_it, fillvalue=None):
                #print ptb_line
                if ptb_tok is None:
                    print >> stderr, ('ERROR: Fewer PTB tokens '
                            'than DEP tokens, line: {}').format(ptb_line_num)
                    return -1
                if dep_tup is None:
                    if ignore_fewer:
                        return 0
                    print >> stderr, 'ERROR: Fewer DEP tokens'
                    return -1
                dep_line_num, dep_tok = dep_tup
                
                # None is a wildcard indication, we can't know due to loss of
                # token information in the data format.
                if dep_tok is None:
                    continue

                if ptb_tok != dep_tok:
                    print >> stderr, ("ERROR: Mismatch ptb: '{}' !=  dep: '{}' "
                            'ptb line: {} dep line: {}').format(
                                    ptb_tok, dep_tok, ptb_line_num, dep_line_num)
                    return -1
    return 0


def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    dep_suffix = '.'
    if argp.dep_suffix is None:
        dep_suffix += argp.dep_format
    else:
        dep_suffix += argp.dep_suffix

    for line in (l.strip() for l in stdin):
        if argp.dep_format == 'conll':
            #TODO: SUFFIX!
            ret = _sanity(line, line + dep_suffix,
                    sent_gen_func=_conllx_sent_gen)
        elif argp.dep_format == 'sd':
            #TODO: SUFFIX!
            ret = _sanity(line, line + dep_suffix,
                    sent_gen_func=_sd_sent_gen, ignore_fewer=True)
        else:
            assert False, 'we got a dep_format that was not recognised'

        if ret != 0:
            print line

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
