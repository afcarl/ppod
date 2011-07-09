#!/bin/sh

# Print at most random n-line(s) from stdin to stdout.
#
# Kudos to Knuth for the algorithms.
#
# Author:  Pontus Stenetorp     <pontus stenetorp se>
# Author:  Goran Topic          <goran is.s.u-tokyo.ac jp>
# Version: 2010-12-03

if [ $# -ne 1 ]
then
    echo "Usage: ${0} sample_size" 1>&2
    exit -1
fi

SAMPLE_SIZE=${1}

echo ${SAMPLE_SIZE} | grep -E '^[0-9]+$' > /dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "${0}: sample_size must be a positive integer" 1>&2
    exit -1
fi

if [ ${SAMPLE_SIZE} -lt 1 ]
then
    echo "${0}: sample_size must be greater than zero" 1>&2
    exit -1
fi

awk "
  BEGIN {
   num = ${SAMPLE_SIZE}
   srand()
  }
  NR <= num {
    buf[NR - 1] = \$0
  }
  NR == num {
    ok = 1
  }
  NR > num {
    rnd = int(rand() * NR)
    if (rnd < num) buf[rnd] = \$0
  }
  END { 
    i = num
    if (ok) {
    while (i--) {
        print buf[i]
       }
    }
    else {
        exit(17)
    }
  }
"

if [ $? -eq 17 ]
then
    echo "${0}: sample size larger than input size" 1>&2
    exit -1
fi
