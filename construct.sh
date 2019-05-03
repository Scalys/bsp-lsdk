#!/bin/sh

UTIL_NAME=`basename $0`
UTIL_DIR=`dirname $0`
cd "$UTIL_DIR"
UTIL_DIR=`pwd`

# LSDK sources
LSDK_SRC="flexbuild_lsdk1903.tgz"
LSDK_SRC_MD5="1efc3535b0255b088c0956e9c4ae3371"
LSDK_SRC_DIR="flexbuild_lsdk1903"

PATCHES_DIR="patches"


usage() {
    cat<<EOF
Usage: $UTIL_NAME
Construct LSDK-based BSP sources.
EOF
}

info() {
    echo "$@"
}

err() {
    echo "Error: $@" >& 2
    exit 1
}


#### Functions

lsdk_src_check() {
    local md5

    info "Checking LSDK sources archive integrity..."
    [ -f "$LSDK_SRC" ] || err "LSDK sources archive '$LSDK_SRC' is missing. Please download it from NXP"
    md5=`md5sum "$LSDK_SRC" | cut -d' ' -f1`
    [ "$md5" = "$LSDK_SRC_MD5" ] || err "LSDK sources archive '$LSDK_SRC' is invalid. Please verify its integrity"
}

lsdk_src_unpack() {
    info "Unpacking LSDK sources..."
    tar xf "$LSDK_SRC" || err "failed to extract LSDK contents"
    mv "$LSDK_SRC_DIR"/* .
    rmdir "$LSDK_SRC_DIR"
}

lsdk_patch() {
    info "Patching LSDK..."

    for patch in `ls -1 $PATCHES_DIR`; do
        git apply --exclude .gitignore "$PATCHES_DIR/$patch"
    done
}


#### Command line arguments parsing

[ "$1" = "-h" -o "$1" = "--help" ] && {
    usage
    exit
}


### Main

if [ ! -f "setup.env" ]; then
    lsdk_src_check
    lsdk_src_unpack
fi
lsdk_patch
