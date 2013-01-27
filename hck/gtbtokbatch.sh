#!/bin/sh

# Batch script for Genia TreeBank (GTB) style tokenisation.
#
# Example:
#
#     find . -name '*.txt' | parallel -m -j ${ADJUST_THIS} gtbtokbatch.sh
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2011-07-23

# Adjust these according to your environment
SUPPORTING_DIR=~/git/bionlp_st_2011_supporting/
GTB_TOK=${SUPPORTING_DIR}/tools/GTB-tokenize.pl

# Suffix to give the tokenised versions of the files
TOK_SUFFIX=tok

# Iterate over all paths given as args and tokenise the files
for ARG in $@
do
    cat ${ARG} | ${GTB_TOK} > ${ARG}.${TOK_SUFFIX}
done
