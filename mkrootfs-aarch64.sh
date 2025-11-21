#!/usr/bin/env bash
set -euo pipefail

IMG="test.img"
MOUNT="/mnt/moss"

sudo mkdir -p "$MOUNT"

if [ ! -f "$IMG" ]; then
    dd if=/dev/zero of="$IMG" bs=1M count=128
    mkfs.vfat -F 32 "$IMG"
fi

if ! mountpoint -q "$MOUNT"; then
    sudo mount -o loop "$IMG" "$MOUNT"
fi

if [ ! -d /tmp/bash ]; then
    git clone https://github.com/bminor/bash.git /tmp/bash
fi


pushd /tmp/bash
if [ ! -f "$MOUNT/bin/bash" ]; then
    ./configure --without-bash-malloc --enable-static-link --host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc
    make

    mkdir -p "$MOUNT/bin"
    cp bash "$MOUNT/bin"
fi
popd

# busybox -- I couldn't get this to build.  I ended up restoring to a third-party static binary which isn't ideal but it get's things running.
pushd "$MOUNT/bin"
if [ ! -f busybox-aarch64-linux-gnu ]; then
    wget https://github.com/shutingrz/busybox-static-binaries-fat/raw/refs/heads/main/busybox-aarch64-linux-gnu
    chmod +x busybox-aarch64-linux-gnu
fi
popd

mkdir -p "$MOUNT/dev"

if mountpoint -q "$MOUNT"; then
    sudo umount "$MOUNT"
fi
