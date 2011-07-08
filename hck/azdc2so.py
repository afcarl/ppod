#!/usr/bin/env python

'''
Convert the AZDC corpus format to the Tsujii Lab Stand-off format.

AZDC Homepage:
http://diego.asu.edu/downloads/AZDC/

Tsujii Lab Stand-off Format Definition:
https://www-tsujii.is.s.u-tokyo.ac.jp/fswiki
    /wiki.cgi?page=Standoff+format+definition

Author: Pontus Stenetorp <pontus stenetorp se>
Version: 2010-11-08
'''

import argparse
import csv
import sys

from xml.sax.saxutils import quoteattr

### Constants
ARGPARSER = argparse.ArgumentParser(description=('Convert the AZDC corpus '
    'format to the Tsujii Lab Stand-off format'))
ARGPARSER.add_argument('standoff_output_file', type=argparse.FileType('w'),
        help='poth to store stand-off annotation for the plain text file')
ARGPARSER.add_argument('text_output_file', type=argparse.FileType('w'),
        help='path to plain text file used by the stand off file')
ARGPARSER.add_argument('-i', '--input', default='-',
        type=argparse.FileType('r'), help='input source (DEFAULT: stdin)')
ARGPARSER.add_argument('-d', '--debug', action='store_true',
        help='enable additional debug output')
###

def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    f_pos_by_doc_id = {}

    if argp.debug:
        print >> sys.stderr, ('DEBUG: reading from {}, will write text '
                'stand-off to {} and plain text to {}').format(
                        argp.input.name,
                        argp.text_output_file.name,
                        argp.standoff_output_file.name)

    # You get a column '' in the end since all columns have a trailing \t
    last_pos = 0
    seen_doc_ids = set()
    for line_id, row in enumerate(csv.DictReader(argp.input, delimiter='\t')):
        if argp.debug:
            print >> sys.stderr, 'DEBUG: converting row number {}, {}'.format(
                    line_id, row)

        # If we have not seen this Doc Id before, write it to the text file
        if row['Doc Id'] not in seen_doc_ids:
            seen_doc_ids.add(row['Doc Id'])
            f_pos_by_doc_id[row['Doc Id']] = last_pos
            argp.text_output_file.write('{}\n'.format(row['Sentence']))
            last_pos += len(row['Sentence']) + 1 # +1 for newline

        # Is this sentence without annotations
        if not row['Start Point'] and not row['End Point']:
            continue

        #TODO: Escape quoting and XML? of the comments?
        argp.standoff_output_file.write(
        #TODO: Should also be maybe PMID
        #TODO: Bunch the attributes together and sort them to make it nicer
        #print (
                ('{begin} {end} {tag_name} {maybe_notes}pmid={pmid} '
                    '{maybe_umls_code}'
                    '{maybe_umls_conc_name}'
                    '{maybe_umls_alt_codes}\n').format(
                    # Compensate for the offset, we are now relative the file
                    begin=(int(row['Start Point'])
                        + f_pos_by_doc_id[row['Doc Id']]),
                    end=(int(row['End Point'])
                        + f_pos_by_doc_id[row['Doc Id']]  + 1),
                    tag_name='disease', # It is a disease corpus
                    maybe_notes=('notes={} '.format(quoteattr(row['Notes']))
                        if row['Notes'] else ''),
                    pmid=quoteattr(row['PMID']),
                    maybe_umls_code=('umls_code={} '.format(
                        quoteattr(row['UMLS Code']))
                        if row['UMLS Code'] else ''),
                    maybe_umls_conc_name=('umls_conc_name={} '.format(
                        quoteattr(row['UMLS Concept Name']))
                        if row['UMLS Concept Name'] else ''),
                    umls_conc_name=row['UMLS Concept Name'],
                    maybe_umls_alt_codes=('umls_alt_codes={}'.format(
                        quoteattr(row['Possible Alternative Codes']))
                        if row['Possible Alternative Codes'] else '')))


if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
