#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "usage: $0 MOUNTPOINT"
    echo ""
    echo "MOUNTPOINT: Mounted directory"
    exit -1
fi

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"   
}

function aborting() {
    printheader $@
    exit 1
}

MOUNTPOINT=$1
MAPCONTAINER=$(findmnt -no SOURCE $MOUNTPOINT)
if [ -z "$MAPCONTAINER" ]; then
    aborting "$MOUNTPOINT is not mounted!"
fi

printheader "Unmounting container"
sudo umount $MOUNTPOINT

printheader "Closing container $MAPCONTAINER"
sudo cryptsetup luksClose $MAPCONTAINER
