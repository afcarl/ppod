#!/bin/sh

# Batch script for the Charniak-Johnson Parser with
# the McClosky Biomedical parsing model (McCCJ). We assume that the input is
# sentence split but not tokenised.
#
# Charniak-Johnson Parser Source Repository:
#
#     https://github.com/dmcc/bllip-parser
#
# McClosky Parsing Model:
#
#     http://www.cs.brown.edu/~dmcc/biomedical.html
#
# Example:
#
#     find . -name '*.ss' | parallel -m -j ${ADJUST_THIS} mcccjbatch.sh
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2011-07-26

# Adjust these to suit your environment
MCCCJ_DIST_DIR=/home/pontus/git/bllip-parser
MCCCJ_MODEL_DIR=/home/pontus/tmp/biomodel

# We piggy-back on the BioNLP ST 2011 repository
BIONLP_ST_2011_REPO=/home/pontus/git/bionlp_st_2011_supporting
GTB_TOK=${BIONLP_ST_2011_REPO}/tools/GTB-tokenize.pl
RESTORE_QUOTES=${BIONLP_ST_2011_REPO}/tools/restore-doublequotes.py

# Suffix to give the parsed versions of the files
MCCCJ_SUFFIX=mcccj

# Iterate over all paths given as args and tokenise the files
for ARG in $@
do
    # There is an error in tokenisation for the McClosky model concerning PTB
    # escaping, we circumvent this with a small hack, just as for BioNLP 2011
    TMP_STD_TOK_FILE=`mktemp`

    # Do standard tokenisation and save it to restore double-quotes later
    cat ${ARG} | ${GTB_TOK} | sed '/^$/d' > ${TMP_STD_TOK_FILE}

    cat ${ARG} | \
        # Tokenise with the special McCCJ option
        ${GTB_TOK} -mccc | \
        # Remove empty lines, the parser stops parsing after a blank line
        sed '/^$/d' | \
        # Insert XML-ish (not XML since they are space sensitive) tags
        sed -e 's|^|<s> |g' -e 's|$| </s>|g' | \
        # Do the parsing using the biomedical model
        # NOTE: Beware of writing `-N 50` instead of `-N50`, space sensitive
        ${MCCCJ_DIST_DIR}/first-stage/PARSE/parseIt -K -l399 -N50 \
            ${MCCCJ_MODEL_DIR}/parser/ | \
        ${MCCCJ_DIST_DIR}/second-stage/programs/features/best-parses \
            -l ${MCCCJ_MODEL_DIR}/reranker/features.gz \
            ${MCCCJ_MODEL_DIR}/reranker/weights.gz | \
        # Restore the appropriate quots, the script is verbose on stderr
        ${RESTORE_QUOTES} ${TMP_STD_TOK_FILE} \
            > ${ARG}.${MCCCJ_SUFFIX} \
            2> /dev/null

    rm -f ${TMP_STD_TOK_FILE}
done
