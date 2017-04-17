#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "usage: $0 SSHFS_MOUNTPOINT CONTAINER_MOUNTPOINT"
    echo ""
    echo "SSHFS_MOUNTPOINT:     Mountpoint where the remote server is mounted to."
    echo "CONTAINER_MOUNTPOINT: Local mountpoint, where the container is mounted."
    exit -1
fi

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"   
}

SSHFS_MOUNTPOINT="$1"
CONTAINER_MOUNTPOINT="$2"

./sb_umount_container.sh $CONTAINER_MOUNTPOINT
printheader "Unmounting sshfs-mountpoint"
fusermount -u $SSHFS_MOUNTPOINT
