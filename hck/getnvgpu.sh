#!/bin/sh
# vim:set ft=sh ts=4 sw=4 sts=4 autoindent:

# Return the id of a Nvidia GPU that has no process attached to it.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2015-10-14

set -o errexit
set -o nounset

lockdir=/tmp/getnvgpu
pidfile="${lockdir}/pid"
numtries=3

strstrip () {
    sed -r -e 's|^\s+||g' -e 's|\s+$||g'
}

availablegpu () {
    nvidia-smi pmon -c 1 | strstrip | sed -e '1,2d' -e 's| \+|\t|g' \
        | cut -f 1,2 | grep '-' | cut -f 1 | head -n 1
}

for attempt in `seq "${numtries}"`
do
    if mkdir "${lockdir}" &> /dev/null
    then
        trap "rm -rf '${lockdir}'" INT TERM EXIT
        echo "$$" > "${pidfile}"
        echo `availablegpu`
        rm -r -f "${lockdir}"
        break
    else
        if [ ${attempt} -ne ${numtries} ]
        then
            # Remove lock if stale.
            if [ -f "${pidfile}" ]
            then
                lockpid=`cat "${pidfile}"`
                if ! kill -0 "${lockpid}" &> /dev/null
                then
                    rm -r -f "${lockpid}"
                fi
            fi
            sleep 1
            continue
        else
            echo 'ERROR: no GPU available' >&2
            exit -1
        fi
    fi
done
