#!/usr/bin/env python

'''
Extract the citation plain-text from the given PubMed XML files. The plain-text
files are on the format: `${CITATION_TITLE}\n${CITATION_ABSTRACT}` and
`${CITATION_TITLE}` if no abstract is present.

Example, converting PubMed 2011 into plain-text files:

    find . -name 'medline11s*.xml' | ./pubmedxml2txt.py txt/

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2010-11-13
'''

# TODO: Should also be able to read XML from stdin

from argparse import ArgumentParser, FileType
from sys import stderr
from os.path import basename, exists
from os.path import join as path_join
from os import mkdir

try:
    import xml.etree.cElementTree as ElementTree
except ImportError:
    import xml.etree.ElementTree as ElementTree

### Constants
ARGPARSER = ArgumentParser(description='Extract plain-text versions of '
        'article contained in PubMed XML')
ARGPARSER.add_argument('output_dir', 
        help='directory where to output the ${PMID}.txt files')
ARGPARSER.add_argument('-f', '--force', action='store_true',
        help='overwrite existing plain-text files')
ARGPARSER.add_argument('-i', '--input', default='-',
        type=FileType('r'), help='input source (DEFAULT: stdin)')
ARGPARSER.add_argument('-p', '--hierarchy', action='store_true',
        help='output files in a hierarchy based on the input files')
ARGPARSER.add_argument('-d', '--debug', action='store_true',
        help='additional debug output')
###

def _xml_elem_to_text(elem):
    return ElementTree.tostring(elem, encoding='utf-8', method='text')

def _pubmed_xml_to_txt_gen(file_handle):
    for event, elem in ElementTree.iterparse(file_handle):
        # Find the medline citations
        if elem.tag != 'MedlineCitation':
            continue

        pmid_elem = elem.find('PMID')
        assert pmid_elem is not None, 'Failed to find PMID element'
        """
        if pmid_elem is None:
            print >> stderr, ('WARNING: Found MedlineCitation '
                    'without PMID element, ignoring citation')
            continue
        """
        pmid = int(pmid_elem.text)
       
        article_elem = elem.find('Article')
        assert article_elem is not None, 'Failed to find article element'
        #if article_elem is None:
        #    continue #TODO: Warning!

        article_title_elem = article_elem.find('ArticleTitle')
        assert article_title_elem is not None, (
                'Failed to fint ArticleTitle element')
        title_text = _xml_elem_to_text(article_title_elem)

        abstract_elem = article_elem.find('Abstract')
        if abstract_elem is not None:
            abstract_text_elem = abstract_elem.find('AbstractText')
            assert abstract_text_elem is not None, (
                    'Failed to find AbstractText element')
            abstract_text = _xml_elem_to_text(abstract_text_elem)
        else:
            abstract_text = None

        yield (pmid, title_text, abstract_text)


def main(args):
    argp = ARGPARSER.parse_args(args[1:])

    if argp.debug:
        print >> sys.stderr, 'DEBUG: reading input from {}'.format(
                argp.input.name)

    if argp.debug:
        total_processed = 0

        from datetime import datetime
        start = datetime.utcnow()
        def print_average_processed(processed):
            if processed > 0:
                print >> sys.stderr, 'DEBUG: {} seconds per article'.format(
                        (datetime.utcnow() - start).seconds
                        / float(processed))

    xml_file_paths = (l.strip() for l in argp.input)

    for xml_file_path in xml_file_paths:
        # Trickery to handle GZipped files reasonably fast
        file_handle = None
        try:
            if xml_file_path.endswith('.gz'):
                import subprocess
                gzip_process = subprocess.Popen(
                        'gunzip -c {}'.format(xml_file_path),
                        stdout=subprocess.PIPE, shell=True)
                file_handle = gzip_process.stdout
            else:
                file_handle = open(xml_file_path, 'r')

            # This is where we actually extract the data, no magic
            for pmid, title, abstract in _pubmed_xml_to_txt_gen(file_handle):
                outfile_path = '{}.txt'.format(pmid)

                if argp.hierarchy:
                    xml_file_basename = basename(xml_file_path)
                    # Strip the file extensions to get the directory name
                    subdir_name = xml_file_basename[:xml_file_basename.find('.')]
                    subdir = path_join(argp.output_dir, subdir_name)

                    if not exists(subdir):
                        mkdir(subdir)

                    output_dir = subdir
                else:
                    output_dir = argp.output_dir
                    
                outfile_path = path_join(output_dir, outfile_path)

                if exists(outfile_path):
                    if not argp.force:
                        print >> stderr, (
                                "'{}' already exists, exiting"
                                ).format(outfile_path)
                        return -1

                with open(outfile_path, 'w') as outfile:
                    outfile.write(title)

                    if abstract is not None:
                        outfile.write('\n')
                        outfile.write(abstract)
                
                if argp.debug:
                    total_processed += 1


        finally:
            if file_handle is not None:
                file_handle.close()
                
        if argp.debug:
            print >> stderr, ("DEBUG: processed '{}'"
                ).format(xml_file_path)
   
    if argp.debug:
        print_average_processed(total_processed)

    return 0

if __name__ == '__main__':
    import sys
    exit(main(sys.argv))
