#!/bin/sh
# vim:set ft=sh ts=4 sw=4 sts=4 autoindent:

# Creates a "bootable" Canon Hack Development Kit (CHDK) card.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2015-02-07

set -o errexit
set -o nounset

statprnt() {
    echo "\033[1m\033[32m$1\033[0m"
}

USAGE="${0} DEV_PATH CHDK_ARCH_PATH"

if [ $# -ne 2 ]
then
    echo "${USAGE}" 1>&2
    exit 1
fi

DEV_PATH=$1
ARCH_PATH=$2

statprnt 'Partitioning'
echo 'o\nn\np\n\n\n+1M\nt\n6\nn\np\n\n\n\n\nt\n\nb\nw\n' \
    | sudo fdisk "${DEV_PATH}"

statprnt 'Formatting'
sudo mkdosfs -F 16 -n CHDK_BOOT "${DEV_PATH}p1"
echo -n BOOTDISK | sudo dd bs=1 count=8 seek=64 of="${DEV_PATH}p1"
sudo mkdosfs -F 32 -n CANON_DC "${DEV_PATH}p2"

statprnt 'Installing'
TMPDIR=`mktemp -d`
trap "rm -r -f ${TMPDIR}" INT TERM EXIT
sudo mount -o 'fat=16' "${DEV_PATH}p1" "${TMPDIR}"
sudo unzip -d "${TMPDIR}" "${ARCH_PATH}" DISKBOOT.BIN
sudo umount "${TMPDIR}"
sudo mount "${DEV_PATH}p2" "${TMPDIR}"
sudo unzip -d "${TMPDIR}" "${ARCH_PATH}"
sudo rm -f "${TMPDIR}/DISKBOOT.BIN"
sudo umount "${TMPDIR}"
rm -r -f "${TMPDIR}"

statprnt "Successful!  Don't forget to lock the card!"
