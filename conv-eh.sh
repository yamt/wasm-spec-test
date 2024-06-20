
#! /bin/sh

set -e
set -x

THIS_DIR=$(cd $(dirname $0) && pwd -P)

# wast2json with a hack https://github.com/yamt/wabt/tree/eh
WASM2JSON=~/git/wabt/b/wast2json

# the spec interpreter from the exception-handling repo
# a few tests are removed manually to allow multi-memory
# https://github.com/yamt/exception-handling/tree/remove-no-multi-memory-assumptions
SPECINTERP=~/git/wasm/exception-handling/interpreter/wasm

# the spec tests from the exception-handling repo
SRCDIR=~/git/wasm/exception-handling/test/core

DSTDIR=${THIS_DIR}/exception-handling/test/core
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
