#!/bin/sh
### ====================================================================
###  @UNIX-shell-file{
###     author          = "Nelson H. F. Beebe",
###     version         = "0.00",
###     date            = "13 October 1992",
###     time            = "19:33:14 MDT",
###     filename        = "bibsort.sh",
###     address         = "Center for Scientific Computing
###                        Department of Mathematics
###                        University of Utah
###                        Salt Lake City, UT 84112
###                        USA",
###     telephone       = "+1 801 581 5254",
###     FAX             = "+1 801 581 4148",
###     checksum        = "35811 163 700 5138",
###     email           = "beebe@math.utah.edu (Internet)",
###     codetable       = "ISO/ASCII",
###     keywords        = "bibliography, sorting, BibTeX",
###     supported       = "yes",
###     docstring       = "This file contains the bibsort utility, a
###                        program for sorting BibTeX data base files
###                        by their BibTeX tag names.
###
###                        The checksum field above contains a CRC-16
###                        checksum as the first value, followed by the
###                        equivalent of the standard UNIX wc (word
###                        count) utility output of lines, words, and
###                        characters.  This is produced by Robert
###                        Solovay's checksum utility.",
###  }
# ====================================================================
# Sort a BibTeX file fragment by citation tags, filtering stdin to
# stdout.
#
# Usage:
#       bibsort [optional sort(1) switches] <infile >outfile
#
# If the sort switches are omitted, -f (ignore letter case
# differences) is used.  "bibsort -f -u" would remove duplicate
# bibliography entries from the input stream.
#
# Note that this operation cannot be done in general, because @string
# and @preamble entries need to come first, and cross-references last.
#
# In general, you should only apply this command to a fragment of a
# .bib file that you know in advance can be sorted.
#
# We deal with leading commentary, @preamble, and @string by giving
# them temporary sort keys that place them before other bibliography
# entries.
#
########################################################################
# WARNINGS:
#
# (1) This simple version does NOT recognize bib entries with outer
# parentheses instead of braces.
#
# (2) It may fail on some UNIX sort implementations that cannot handle
# very long lines, because for sorting purposes, each complete bib
# entry is temporarily folded into a single line.  You may be able to
# overcome this problem by adding a -z nnnnn switch to the sort
# command to set the maximum line size to nnnnn bytes.
#
########################################################################
#
# The sorting is implemented as a filter pipeline:
#
# Stage 1 (nawk) finds bib file entries and prefixes them with a line
# containing a sort key, where each such line begins with a Ctl-E, and
# the file ends with Ctl-E.
#
# Stage 2 (tr) turns LF into Ctl-G and Ctl-E into LF.  This hides
# line boundaries and makes each item a separate `line'.
#
# Stage 3 (sort) sorts `lines' (i.e. bib entries), ignoring
# letter case differences.
#
# Stage 4 (tr) turns LF into Ctl-E, and Ctl-G back into LF.  This
# restores the original line boundaries.
#
# Stage 5 (tr) deletes all Ctl-E and Ctl-F characters.
#
# Stage 6 (egrep) removes the sort key lines.
#

if [ $# -gt 0 ]
then
	SORTFLAGS="$*"
else
	SORTFLAGS="-f"
fi

nawk '
BEGIN {
        sort_prefix = "\005"
        sort_key = sort_prefix "%%SORTKEY:"
        hidden_newline = "\006"
        print sort_key "\001" hidden_newline
}

/^@[Pp][Rr][Ee][Aa][Mm][Bb][Ll][Ee]{/ {
        k = index($0,"{") + 1
        print sort_key "\002" substr($0,k) hidden_newline
        printbraceditem()
        next
}
/^@[sS][tT][rR][iI][nN][gG]{/ {
        k = index($0,"{") + 1
        m = index($0,"=")
        print sort_key "\003" substr($0,k,m-k) hidden_newline
        printbraceditem()
        next
}

# "@keyword{tag,"
/^@[a-zA-Z0-9]*{/       {
        k = index($0,"{") + 1
        m = index($0,",")
        print sort_key "\004" substr($0,k,m-k) hidden_newline
        print
        next
}

{ print }

END { printf(sort_prefix) }

function bracecount(s, k,n)
{
    n = 0
    for (k = 1; k <= length(s); ++k)
    {
        if (substr(s,k,1) == "{")
            n++
        else if (substr(s,k,1) == "}")
            n--
    }
    return (n)
}

# Starting with the current contents of $0, print lines until we
# reach a zero brace count.

function printbraceditem(count)
{
    count = bracecount($0)
    print $0
    while (count != 0)
    {
        if (getline <= 0)
            break
        printf("%s\007",$0)
        count += bracecount($0)
    }
}
' | \
        tr '\012\005' '\007\012' | \
        sort ${SORTFLAGS} | \
        tr '\007\012' '\012\005' | \
        tr -d '\005\006' | \
        egrep -v  '^%%SORTKEY:'
################################[The End]###############################
