#!/bin/bash

if [[ $# -ne 4 ]] && [[ $# -ne 5 ]]; then
    echo "usage: $0 REMOTE_SOURCE SSHFS_MOUNTPOINT CONTAINER MOUNTPOINT [KEYFILE]"
    echo ""
    echo "REMOTE_SOURCE:    ssh-resolvable Server-Address (something like user@server:/my/path)"
    echo "SSHFS_MOUNTPOINT: Local mountpoint to mount REMOTE_SOURCE into"
    echo "CONTAINER:        Relative path to remote container-file, without SSHFS_MOUNTPOINT in front"
    echo "MOUNTPOINT:       Local empty directory to mount container-file into"
    echo "KEYFILE:          Optional! If keyfile is provided, no password will be prompted during mount"
    exit -1
fi

REMOTE_SOURCE="$1"
SSHFS_MOUNTPOINT="$2"
CONTAINER="$3"
MOUNTPOINT="$4"
if [[ $# -eq 5 ]]; then
    KEYFILE="$5"
fi

function printheader() {
    echo "**************************************"
    echo "$@"
    echo "**************************************"
}

function aborting() {
    printheader $@
    sudo fusermount -u $SSHFS_MOUNTPOINT
    exit 1
}

printheader "Mounting remote directory"
sshfs -o allow_other "$REMOTE_SOURCE" "$SSHFS_MOUNTPOINT" || aborting "Failed to mount remote directory"
./sb_mount_container.sh "$SSHFS_MOUNTPOINT/$CONTAINER" "$MOUNTPOINT" $KEYFILE || aborting "Failed to mount local container!"
