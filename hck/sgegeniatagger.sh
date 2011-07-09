#!/bin/sh
#
# Parse the whole of a PubMed distribution contained in gzipped tarballs
# reasonably parallel using a single shell script.
#
# We assume several things only applicable to the Tsujii Laboratory servers:
#   * We have access to GNU parallel
#   * SGE handles scheduling
#   * We have access to this script using the same path on the target machines
#   * There is a directory ~/workdirs/`hostname -s`/`whoami` we can use,
#       you could easily switch this one out for another work directory
# 
# Author: Pontus Stenetorp <pontus stenetorp se>
# Version: 2010-11-25


### Variables go here
# MAX_SGE_JOBS can be a path to a file with a number to be adjusted at run-time
MAX_SGE_JOBS=4
DEBUG=0
# We require genia tagger with my patches applied, see the same repo
GENIA_TAGGER_DIR=~/work/geniatagger-3.0.1_patched/
# No NER speeds up genia tagger considerably, set to '' for NER, otherwise '-n'
NER=''
###

### Command line parsing and checks
if [ $# -ne 2 ]
then
    echo "Usage: ${0} PUBMED_TAR_GZ_SRC_DIR OUTPUT_DIR" 1>&2
    exit -1
fi

if [ ! -r ${1} ]
then
    echo "${0}: could not read '${1}', exiting" 1>&2
    exit -1
fi

if [ ! -r ${2} ]
then
    echo "${0}: could not read '${2}', exiting" 1>&2
    exit -1
fi

if [ ! -d ${2} ]
then
    echo "${0}: '${2}' is not a valid directory" 1>&2
    exit -1
fi

# Set up some variables for later use
THIS_SCRIPT=`readlink -f ${0}`
WORKDIR_DIR_NAME=tmp/`basename ${0}`
OUTPUT_DIR=`readlink -f ${2}`

# If we are debugging, we need to set up a few things
if [ ${DEBUG} -eq 1 ]
then
    PARALLEL_VERBOSE='-v'
else
    PARALLEL_VERBOSE=''
fi

# If we were passed a directory, we are the starter script
if [ -d ${1} ]
then
    PUBMED_TAR_GZ_DIR=`readlink -f ${1}`
    if [ ${DEBUG} -eq 1 ]
    then
        echo 'DEBUG: We are running in debug mode' 1>&2
    fi

    # Search the directory for gzipped tarballs and schedule SGE jobs
    find ${PUBMED_TAR_GZ_DIR} -name '*.tar.gz' | \
        # Then spawn a SGE job for each file
            parallel --retries 17 -n 1 -j ${MAX_SGE_JOBS} \
                ${PARALLEL_VERBOSE} -I {} \
                    qrsh ${THIS_SCRIPT} {} ${OUTPUT_DIR}

    # Do a simple check to see if we really appear to have parsed it all
    MISSING=`qrsh "find ${PUBMED_TAR_GZ_DIR} ${OUTPUT_DIR} \
                    -type f -name '*.tar.gz' \
            | parallel tar tfz | grep -v -E '/$'\
            | sed -r -e 's|\.txt$||g' -e 's|\.txt.gtag$||g' \
            | sort | uniq -c | grep -E '^\ +1\ +' \
            | sed -r -e 's|\ +[0-9]+\ +||g' -e 's|/[0-9]+$||g' | sort | uniq"`

    # If it looks fishy, alert the user so that he may act upon it
    if [ "${MISSING}" != "" ]
    then
        echo 'ERROR: Source files missing or lacking PMID files:' 1>&2
        # TODO: Not sure if it will print 100% as intended, but it will print
        echo `echo ${MISSING} | \
                sed -r -e "s|^|${SRC_DIR}/|g" -e "s|$|.tar.gz|g" \
                        -e "s|\ |.tar.gz\n${SRC_DIR}/|g"` 1>&2
        exit -1
    else
        exit 0
    fi
else
    # Create our work directory and extract the data into it
    PUBMED_TGZ_FILE=${1}
    WRK_DIR=~/workdirs/`hostname -s`/${WORKDIR_DIR_NAME}
    DATA_DIR=${WRK_DIR}/`basename ${PUBMED_TGZ_FILE} | \
        perl -pe 's|(.*?)\..*|\1|'`

    # Making the directory like this ensures a non-empty dir when cleaning
    mkdir -p ${DATA_DIR}
    tar xfz ${1} -C ${WRK_DIR}


    # We may run into an old session, clean out any old parses
    find ${DATA_DIR} -type f -name '*.txt.gtag' -print0 | xargs -r -0 rm
    
    # Geniatagger sucks, so we need to change our working directory to use it
    cd ${GENIA_TAGGER_DIR}
    # Then parse at full speed using our patched geniatagger
    find ${DATA_DIR} -type f -name '*.txt' | ./geniatagger ${NER} -o -l -f -q
    
    # Clear out the now unnecessary raw texts
    find ${DATA_DIR} -type f -name '*.txt' -print0 | xargs -r -0 rm

    # Create a gzipped tarball and move it back to the output dir
    cd ${WRK_DIR}
    RESULTS_FILE=`basename ${DATA_DIR}`.tar.gz
    tar cfz ${RESULTS_FILE} `basename ${DATA_DIR}`
    mv ${RESULTS_FILE} ${OUTPUT_DIR}

    # Clean up after us, and if we were the last one out, remove the work dir
    rm -rf ${DATA_DIR}
    if [ -z "`ls ${WRK_DIR}`" ]
    then
        # Could be harmful if we ran into another process, but we have no locks
        rm -rf ${WRK_DIR}
    fi

    if [ ${DEBUG} -eq 1 ]
    then
        echo "DEBUG: processed `basename ${PUBMED_TGZ_FILE}`" 1>&2
    fi

    exit 0
fi
