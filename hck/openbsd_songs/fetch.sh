#!/bin/sh
# vim:set ft=sh ts=4 sw=4 sts=4 autoindent:

# Fetch all OpenBSD release songs.
#
# Note: Yes, I realise the irony in fetching BSD music using wget.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-05-25

set -o errexit
set -o nounset

OPENBSD_SONGS=http://www.openbsd.org/songs/

wget -r --no-parent --no-directories --accept ogg ${OPENBSD_SONGS}
# Clean-up
rm -f index.html robots.txt
