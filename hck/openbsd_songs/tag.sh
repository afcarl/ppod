#!/bin/sh

# Semi-automagically tag your newly fetched OpenBSD release songs.
#
# Uses lltag:
#
#   sudo apt-get install lltag
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-05-25

TAG_LIST=tag.list

for ogg_file in `ls *.ogg`
do
    title=`grep "^${ogg_file}" ${TAG_LIST} | cut -f 2`
    if [ -z "${title}" ]
    then
        echo "WARNING: no entry in ${TAG_LIST} for ${ogg_file}, skipping" 1>&2
        continue
    fi
    lltag --yes --clear ${ogg_file} > /dev/null
    lltag --yes --ARTIST 'OpenBSD' --ALBUM 'OpenBSD' --TITLE "${title}" \
        "${ogg_file}" > /dev/null
done
