#!/bin/bash

if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
    echo "usage: $0 CONTAINER MOUNTPOINT [KEYFILE]"
    echo ""
    echo "CONTAINER:  Full path to container-file"
    echo "MOUNTPOINT: Empty directory to mount into"
    echo "KEYFILE:    Optional! If keyfile is provided, no password will be requested during mount."
    exit -1
fi

CONTAINERNAME=container
CONTAINER=$1
MOUNTPOINT=$2
if [[ $# -eq 3 ]]; then
    KEYFILE="--key-file $3"
fi

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"
}

function aborting() {
    printheader $@
    sudo cryptsetup luksClose $CONTAINERNAME
    exit 1
}

printheader "Opening Container"
sudo cryptsetup $KEYFILE luksOpen $CONTAINER $CONTAINERNAME || aborting "luksOpen failed!"
printheader "Mounting Container"
sudo mount -t ext4 /dev/mapper/$CONTAINERNAME $MOUNTPOINT || aborting "Mounting failed!"
