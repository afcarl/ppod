#!/bin/sh
# vim:set ft=sh ts=4 sw=4 sts=4 autoindent:

# Simple USB key installation creation script.
#
# There are two reasons for the existence of this script:
#   1.) I find it far more reliable than the Ubuntu "Startup Disk Creator".
#   2.) I can never for the life of me remember these simple commands given how
#       rarely I use them.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2015-12-24

# TODO: Argument checking, we are currently going down in flames.

USAGE="${0} iso_path device"

set -o errexit
set -o nounset

if [ $# -lt 2 ]
then
    echo ${USAGE} 1>&2
    exit 1
fi
iso="${1}"
dev="${2}"

sudo dd if="${iso}" of="${dev}" bs=16M
sync
