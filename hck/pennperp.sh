#!/bin/sh

# Find which PTB line(s) that crashes the LTU Pennconverter. Use together with
# `pennconverter.sh` (or hack it out if you prefer).
#
#   http://nlp.cs.lth.se/software/treebank_converter/
#
# Note: Necessary since the tool itself dies, it does give you the exit code
# though (thank you Richard!)
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-05-24

line_cmd () {
    awk "NR == ${1}" ${2}
}

PTB_FILE=${1}
SCRIPT_DIR=`dirname ${0}`
PENNCONVERTER_SH=${SCRIPT_DIR}/pennconverter.sh

PTB_NUM_LINES=`wc -l ${PTB_FILE} | cut -f 1 -d ' '`

for LINE_NUM in `seq ${PTB_NUM_LINES}`
do
    LINE=`line_cmd ${LINE_NUM} ${PTB_FILE}`
    echo ${LINE} | ${PENNCONVERTER_SH} > /dev/null 2>&1
    if [ ${?} != 0 ]
    then
        echo -e ${LINE_NUM} '\t' ${LINE}
    fi
done
