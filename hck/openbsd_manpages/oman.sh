#!/bin/sh

# Fetch and organise OpenBSD manpages using cvs.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2012-10-05

set -e

if [ $# -ne 2 ]
then
    echo "Usage: ${0} OPENBSD_VERSION TARGET_DIR" 1>&2
    exit 1
fi

OPENBSD_VER=${1}
TARGET_DIR=${2}

TAG_VER=`echo ${OPENBSD_VER} | sed -e 's|\.|_|g'`
TAG_SHORT=`echo ${OPENBSD_VER} | sed -e 's|\.||g'`
ARCH=`uname -m | sed -e 's|i[3-6]86|i386|g' -e 's|x86_64|amd64|g'`

CVS_TAG="OPENBSD_${TAG_VER}"
CVS_URL='anoncvs@anoncvs.ca.openbsd.org'
FTP_URL='http://ftp.openbsd.org/pub/OpenBSD/'
MAN_TGZ_URL="${FTP_URL}/${OPENBSD_VER}/${ARCH}/man${TAG_SHORT}.tgz"

TMP_MAN_DIR=`mktemp -d`
TMP_CVS_DIR=`mktemp -d`
trap "rm -rf ${TMP_MAN_DIR} ${TMP_CVS_DIR}" INT TERM EXIT

# Fetch the gzipped manpage tar
wget -qO- ${MAN_TGZ_URL} | tar -z -x -C ${TMP_MAN_DIR} -f -

# Check out libc
(cd ${TMP_CVS_DIR} && \
    cvs -Q -d ${CVS_URL}:/cvs get -r ${CVS_TAG} -P src/lib/libc)

# Copy the whole man-page structure
cp -r ${TMP_MAN_DIR}/usr/share/man ${TARGET_DIR}

# Lift in the libc manpages in place
for INDEX in `seq 1 9`
do
    MAN_DPATH="${TARGET_DIR}/man${INDEX}"
    mkdir -p ${MAN_DPATH}
    for MAN_FPATH in `find ${TMP_CVS_DIR}/src/lib/ -name "*.${INDEX}"`
    do
        cp -f ${MAN_FPATH} ${MAN_DPATH}
    done
done
