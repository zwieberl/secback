#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "usage: $0 CONTAINERNAME KEYNAME"
    echo ""
    echo "CONTAINERNAME: Full path to container-file"
    echo "KEYNAME:       Name of the additional keyfile which is created and added to the container"
    exit -1
fi

filename="$1"
KEYNAME="$2"

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"
}

printheader "Creating keyfile $KEYNAME"
[[ -f $KEYNAME ]] && aborting "File $KEYNAME already exists! Aborting!"

# keysize = 64, because 512 bit
dd if=/dev/random of="$KEYNAME" bs=1 count=64
cryptsetup luksAddKey "$filename" "$KEYNAME"
