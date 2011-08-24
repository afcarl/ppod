#!/bin/sh

# Batch script for sentence splitting with GeniaSS. If you don't have
# the patched version of GeniaSS that supports `-q` remove it and enjoy
# model loading messages on `stderr`.
#
# Patched GeniaSS:
#
#    https://github.com/ninjin/geniass
#
# Example:
#
#     find . -name '*.txt' | parallel -m -j ${ADJUST_THIS} geniassbatch.sh
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2011-07-16

# Adjust these according to your environment
GENIA_SS_DIR=~/git/geniass/
SUPPORTING_DIR=~/git/bionlp_st_2011_supporting/
# We use the post-processing script to conform with BioNLP ST 2011
GENIA_SS_POSTPROC=${SUPPORTING_DIR}/tools/geniass-postproc.pl

# Suffix to give the sentence splitted version of the files
SS_SUFFIX=ss

# Iterate over all paths given as args and sentence split the files
for ARG in $@
do
    INPUT_FILE=`readlink -f ${ARG}`
    OUTPUT_FILE=${INPUT_FILE}.${SS_SUFFIX}

    # GeniaSS needs a stupid temporary file for output...
    SS_TMP=`mktemp`

    (
    cd ${GENIA_SS_DIR} &&
        ./geniass -q ${INPUT_FILE} ${SS_TMP} &&
        ${GENIA_SS_POSTPROC} ${SS_TMP} > ${OUTPUT_FILE}
    )

    rm -f ${SS_TMP}
done
