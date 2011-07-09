#!/bin/sh

# Segment an input file 
#
# Author:  Pontus Stenetorp <pontus stenetorp se>
# Version: 2010-12-03

#TODO: Work in progress!
echo 'WARNING: Work in progress!' 1>&2

#if [ $# -ne 1 ]
#then
#    echo "Usage: ${0} sample_size" 1>&2
#    exit -1
#fi
#
#SAMPLE_SIZE=${1}
#
#echo ${SAMPLE_SIZE} | grep -E '^[0-9]+$' > /dev/null 2>&1
#if [ $? -ne 0 ]
#then
#    echo "${0}: sample_size must be a positive integer" 1>&2
#    exit -1
#fi
#
#if [ ${SAMPLE_SIZE} -lt 1 ]
#then
#    echo "${0}: sample_size must be greater than zero" 1>&2
#    exit -1
#fi
#

SEGMENTS=$1
INPUT_FILE=$2

#TODO: Verify that all segments are numbers

slice_input () {
    INPUT=$1
    FROM=$2
    LINES=$3
    head -n `expr ${FROM} + ${LINES}` ${INPUT} | tail -n ${LINES}
    return 0
}

LINES=`wc -l ${INPUT_FILE} | cut -d ' ' -f 1`

SEGMENT_ARRAY=`eval "echo ${SEGMENTS} | sed -e 's|:| |g'"`
SEGMENT_TOTAL=0

for SEGMENT in ${SEGMENT_ARRAY[@]}
do
    #echo ${SEGMENT}
    SEGMENT_TOTAL=`expr ${SEGMENT_TOTAL} + ${SEGMENT}`
done
#echo ${SEGMENT_TOTAL}

SEGMENT_LINES_TOTAL=0
SEGMENT_SIZES=''
for SEGMENT in ${SEGMENT_ARRAY[@]}
do
    # + 0.5 to do the rounding properly
    SEGMENT_LINES=`echo | awk "{ printf \"%i\",
            ${SEGMENT} * (${LINES} / ${SEGMENT_TOTAL}) + 0.5 }"`
    SEGMENT_SIZES="${SEGMENT_SIZES} ${SEGMENT_LINES}"
    SEGMENT_LINES_TOTAL=`expr ${SEGMENT_LINES_TOTAL} + ${SEGMENT_LINES}`
done

if [ ${LINES} -ne ${SEGMENT_LINES_TOTAL} ]
then
    echo "${0}: ${LINES} not divisible into segments ${SEGMENTS}"
    exit -1
fi

PROCESSED_TOTAL=0
ITERATION=0
for SEGMENT_SIZE in ${SEGMENT_SIZES}
do
    slice_input ${INPUT_FILE} ${PROCESSED_TOTAL} ${SEGMENT_SIZE} \
            > ${INPUT_FILE}.${ITERATION}
    PROCESSED_TOTAL=`expr ${PROCESSED_TOTAL} + ${SEGMENT_SIZE}`
    ITERATION=`expr ${ITERATION} + 1`
done
