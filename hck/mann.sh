#!/bin/sh

# Retrieve a (hopefully) interesting random man page for your pleasure.
#
# Initially proposed by carbonitewang at:
#
#    http://www.reddit.com/r/commandline/comments/w0x1a/
#        i_made_a_shell_script_that_displays_a_random_man/
#
# This script relies on shell variables instead of hardcoding a single man
# page source and incorporates some suggestions by other redditors made in the
# same post.
#
# Script name carries a small Team Fortress 2 reference.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-07-05

# TODO: Commandline parsing

MANDIRS=`manpath | sed -e 's|:| |g'`
# TODO: Warn and exit if MANDIRS is empty

# TODO: Where does other shells store their history?
# cut -f 1 -d ' ' ~/.bash_history | sort | uniq | xargs -n 1 basename | sort | uniq
# TODO: Filter out these commands

# TODO: Currently doesn't take your locale into consideration
# TODO: Does it even occur than manpages are not compressed and stored as *.1?
# TODO: Far too slow, find a speed-up for basename
find ${MANDIRS} -name '*.1.gz' | sed -e 's|\.1\.gz$||g' | sort | uniq | xargs -n 1 basename | sort | uniq | shuf -n 1 | xargs man
