#!/bin/sh

# Fetch all OpenBSD release songs.
#
# Note: Yes, I realise the irony in fetching BSD music using wget.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-05-25

OPENBSD_SONGS=http://www.openbsd.org/songs/

wget -r --no-parents --no-directories --accept ogg ${OPENBSD_SONGS}
# Clean-up
rm -f index.html robots.txt
