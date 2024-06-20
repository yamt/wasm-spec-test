
#! /bin/sh

set -e
set -x

THIS_DIR=$(cd $(dirname $0) && pwd -P)
WASM2JSON=~/git/wabt/b/wast2json
SPECINTERP=~/git/wasm/exception-handling/interpreter/wasm
SRCDIR=~/git/wasm/exception-handling/test/core
DSTDIR=${THIS_DIR}/tmp
TMP=$(mktemp -d)

conv()
{
    BINWAST=${DSTDIR}/$1.bin.wast
    REDUCEDWAST=${TMP}/$1.wast
    JSON=${DSTDIR}/$1.json
    ${SPECINTERP} -d ${SRCDIR}/$1.wast -o ${BINWAST}
    python3 ${THIS_DIR}/extractwasm.py ${BINWAST} > ${REDUCEDWAST}
    ${WASM2JSON} --no-check --enable-exceptions ${REDUCEDWAST} -o ${JSON}
    python3 ${THIS_DIR}/extractwasm.py ${BINWAST} > /dev/null
}

echo "TMP: ${TMP}"

# Note: imports.wast has three cases which fails with multi-memory
conv imports
conv try_table
conv tag
conv throw
conv throw_ref
conv ref_null
