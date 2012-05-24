#!/bin/sh

# Some minor preprocessing that is necessary (but easy to forget) when using
# the LTH PTB converter.
#
#   http://nlp.cs.lth.se/software/treebank_converter/
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-05-17

SCRIPT_DIR=`dirname ${0}`

# Saving Private Converter (from crashing):
#
# 1.) The converter only tolerates certain "root" names.
# 2.) Although "\/" is the correct PTB escape for "/", it kills the converter
# 3.) It dislikes "+/-" being a "preposition" or "to"...
sed \
    -e 's|(ROOT |(TOP |g' \
    -e 's|\\/|/|g' \
    -e 's|(\(IN\|TO\) +/-)|(NN +/-)|g' \
    | java -jar ${SCRIPT_DIR}/pennconverter.jar -splitSlash=false -raw
exit $?
