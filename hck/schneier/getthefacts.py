#!/usr/bin/env python

'''
Author: Pontus Stenetorp
Version: 2008-??-??

Fetches all the Bruce Schneier facts from the web and prints a fortune text
file that can later be converted into a fortune file.

Slight re-work carried out at 2009-07-26. Pythonized and added more doc.

Run: 'strfile facts facts.dat' to produce the final file for fortune.

TODO: Might need more filters, all output has not yet been verified.
'''

from re import compile, IGNORECASE
from sys import argv, exit, stderr
from textwrap import TextWrapper
from time import sleep
from urllib2 import urlopen, Request, HTTPError, URLError

### Cons
DEBUG = False # Debug messes up the output

LAST_FACT = 10 #1397  # Needs to be adjusted as news facts are added
EXTRACT_FACTS = xrange(LAST_FACT + 1)

BASE_URL = 'http://geekz.co.uk/schneierfacts/fact/%s'
BEGIN_TAG = '<p class="fact">'
END_TAG = '</p>'

OUTPUT_WIDTH = 70
TAB_WIDTH = 2

BE_HONEST = True
FAKE_USER_AGENT = ('Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; '
    'rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6')

QUOTE_REGEXP = compile(r'(?P<fact>^"([A-Za-z0-9\ .,!])*?"([\ ])*?)(--?)'
        '([\ ]*?)(?P<who>Bruce Schneier)')
REPLACE_FILTER = (
        (compile(r'&quot;'), '"'),
        (compile(r'&gt;'), '>'),
        (compile(r'&lt;'), '<'),
        (compile(r'<.*?>'), ' '),
        (compile(r'\r'), ' '),
        (compile(r'\n'), ' '),
        (compile(r' +'), ' '),
        (compile(r'(\.\.\.)\.+'), '...'),
        (compile(r'Bruce Schneier the Ladykiller:'), ''),
        (compile(r'Bruce Schneier', flags=IGNORECASE), 'Bruce Schneier'),
        )
###

class Fact(object):
    def __init__(self, fact, number, quote=None):
        self.fact = fact
        self.number = number
        self.quote = quote

def _extract_data():
    data = []

    for index, fact_number in enumerate(EXTRACT_FACTS):
        if DEBUG:
            print >> stderr, 'Sleeping one second to ease the burden on the server...'
        sleep(1)

        if DEBUG:
            print >> stderr, 'Requesting quote:', '%s/%s' % (index, len(EXTRACT_FACTS))
        url = BASE_URL % fact_number
        req = Request(url)
        if not BE_HONEST:
            req.add_header('User-Agent', FAKE_USER_AGENT)
        try:
            resp = urlopen(req)
        except HTTPError:
            if DEBUG:
                print >> stderr, '404 error for %s' % url
            continue
        except URLError, error:
            if DEBUG:
                print >> stderr, 'Received URLError:', error
            continue

        source = resp.read()
        if BEGIN_TAG in source:
            fact = source[source.find(BEGIN_TAG) + len(BEGIN_TAG):
                source.find(END_TAG, source.find(BEGIN_TAG))]
            if DEBUG:
                print >> stderr, 'Fact:', fact

            fact = fact.strip()
            for regexp, replace in REPLACE_FILTER:
                fact = regexp.sub(replace, fact)
            fact = fact.strip()

            if DEBUG:
                print >> stderr, 'Post-filter:', fact

            match = QUOTE_REGEXP.search(fact)
            if match:
                (fact, quote) = (match.groupdict()['fact'].strip(),
                        match.groupdict()['who'])
            else:
                quote = None
       
            fact = fact.replace('--', '-')
            if fact[-1] not in '!.?"\'':
                fact = fact + '.'

            if DEBUG:
                print >> stderr, 'Final-fact:', fact
                if quote:
                    print >> stderr, 'Quote:', quote
                else:
                    print >> stderr, 'No quote found...'

            data.append(Fact(fact, fact_number, quote))
        else:
            if DEBUG:
                print >> stderr, 'No quote found, proceeding...'
            continue
    return data
    
def _save_data(data):
    wrapper = TextWrapper(width=OUTPUT_WIDTH, fix_sentence_endings=True,
            break_long_words=False, subsequent_indent=' '*TAB_WIDTH)

    for fact in data:
        for line in wrapper.wrap(fact.fact):
            print line
        if fact.quote:
            print ' ' * (TAB_WIDTH * 2 - 1), '--', fact.quote
        print
        print ' ' * (TAB_WIDTH * 2 - 1),
        print '-- Bruce Schneier fact #%s' % fact.number
        print '%'

def main(argv=None):
    if DEBUG:
        print >> stderr, 'Will extract Schneier facts...'
    data = _extract_data()
    if DEBUG:
        print >> stderr, 'Saving Schneier facts...'
    _save_data(data)
    return 0

if __name__ == '__main__':
    exit(main(argv=argv))
