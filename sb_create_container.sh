#!/bin/bash

if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
    echo "usage: $0 FILENAME SIZE [KEYNAME]"
    echo ""
    echo "FILENAME: Full path to container-file"
    echo "SIZE:     Size of pre-allocted container in MB"
    echo "KEYNAME:  Optional! If given, an additional keyfile is created and added to the container"
    exit -1
fi

TMPCONTAINER=/tmp/container
CONTAINERNAME=container
MAPCONTAINER=/dev/mapper/$CONTAINERNAME

filename="$1"
size="$2"

if [[ $# -eq 3 ]]; then
    KEYNAME="$3"
fi

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"
}

function cleanup() {
    [ -d $TMPCONTAINER ] && (sudo umount $TMPCONTAINER; echo "Removing $TMPCONTAINER"; rm -rf $TMPCONTAINER)
    sudo cryptsetup luksClose $CONTAINERNAME
}

function aborting() {
    printheader $@
    cleanup
    [ -f "$filename" ] && (echo "Removing $filename"; rm $filename)
    exit 1
}

printheader "Creating container-file"
dd if=/dev/urandom of=$filename bs=1M count=$size || aborting "Creating file with dd failed"
printheader "Initializing container-file with LUKS"
sudo cryptsetup -s 512 -h sha512 -y luksFormat $filename || aborting "luksFormat failed"
printheader "Opening new container-file"
sudo cryptsetup luksOpen $filename $CONTAINERNAME || aborting "luksOpen failed"
printheader "Formatting container-file with ext4"
sudo mkfs.ext4 $MAPCONTAINER || aborting "Formatting container to ext4 failed"
printheader "Mounting new container-file"
mkdir -p $TMPCONTAINER || aborting "Creating $TMPCONTAINER failed"
sudo mount -t ext4 $MAPCONTAINER $TMPCONTAINER || aborting "Mounting failed"
sudo chown -R $(whoami) $TMPCONTAINER

if [ -n "$KEYNAME" ]; then
    printheader "Creating keyfile $KEYNAME"
    [[ -f $KEYNAME ]] && aborting "File $KEYNAME already exists! Aborting!"

    # keysize = 64, because 512 bit
    dd if=/dev/random of="$KEYNAME" bs=1 count=64
    cryptsetup luksAddKey "$filename" "$KEYNAME"
fi

cleanup
