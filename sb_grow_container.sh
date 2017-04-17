#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "usage: $0 CONTAINERFILE INCRSIZE"
    echo ""
    echo "CONTAINERFILE: Full path to container-file"
    echo "INCRSIZE:      How many MB should be appended"
    exit -1
fi

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"   
}

function cleanup() {
	sudo cryptsetup luksClose $CONTAINERNAME
}

function aborting() {
    printheader $@
    cleanup
    printheader "WARNING: Your container might already be increased in size! Please check and if so, start this script again with INCRSIZE = 0 !"
    exit 1
}

CONTAINERFILE=$1
INCRSIZE=$2
CONTAINERNAME=container

if losetup -a | grep $CONTAINERFILE; then
	printheader "$CONTAINERFILE is currently mounted! Please unmount first"
	exit 1
fi

dd if=/dev/urandom bs=1M count=$INCRSIZE >> $CONTAINERFILE || aborting "Failed to grow container-file with dd"

sudo cryptsetup luksOpen $CONTAINERFILE $CONTAINERNAME || aborting "luksOpen failed!"

sudo cryptsetup resize $CONTAINERNAME || aborting "luks resize failed!"

sudo e2fsck -f /dev/mapper/$CONTAINERNAME || aborting "e2fsck failed!"
sudo resize2fs /dev/mapper/$CONTAINERNAME || aborting "resizing failed"

cleanup