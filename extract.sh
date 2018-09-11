#!/bin/bash

MACHINES[0]="comex"

STRATEGYS[0]="build"
STRATEGYS[1]="stable"
STRATEGYS[2]="daily-build"
STRATEGYS[3]="krogoth"
STRATEGYS[4]="morty"
STRATEGYS[5]="pyro"
STRATEGYS[6]="rocko"
STRATEGYS[7]="sumo"

STRATEGY=$1
MACHINE=$2
DIR=$3

# Now, can be defined at environment the variable and if not default value will be used.
: ${YOCTO_DIR:="falcon"}
: ${ORIG:="$HOME/peregrine/$YOCTO_DIR/$STRATEGY/tmp/deploy/images/$MACHINE"}
: ${DEST:="$HOME/peregrine/rootfs/$MACHINE/rootfs"}

promptyn () {
    while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}
contains_strategy () {
    CHECK=$1
    for i in "${STRATEGYS[@]}"
    do
        if [ "$i" == "$CHECK" -o "$i-next" == "$CHECK" -o "$i-review" == "$CHECK" ] ; then
            return 1
        fi
    done

    return 0
}
contains_machine () {
    CHECK=$1
    for i in "${MACHINES[@]}"
    do
        if [ "$i" == "$CHECK" ] ; then
            return 1
        fi
    done

    return 0
}

usage () {
    echo "Usage: extract <STRATEGY> <MACHINE> [<DIRECTORY>]"
    echo "  default dir: ~/peregrine/rootfs/<machine>/rootfs"
    echo "  valid strategy: <STRATEGY>[-next]"
    for i in "${STRATEGYS[@]}"
    do
        echo "    $i"
    done
    echo "  valid machines:"
    for i in "${MACHINES[@]}"
    do
        echo "    $i"
    done
}

if [ "$#" -lt 2 ]; then
  echo "No parameters!"
  usage
  exit 1
fi
if [ "$#" -gt 3 ]; then
  echo "To many parameters!"
  usage
  exit 1
fi
if contains_strategy $STRATEGY; then
  echo "$STRATEGY is a Invalid strategy!"
  usage
  exit 1
fi
if contains_machine $MACHINE; then
  echo "$MACHINE is a Invalid machine!"
  usage
  exit 1
fi
if [ "$#" -eq 3 ]; then
  DEST=$DIR
fi
if ! [ -e "$DEST" ]; then
  echo "DEST=$DEST"
  if promptyn "Must create this directory?"; then
    sudo mkdir -p $DEST
  else
    exit 0
  fi
fi
if ! [ -d "$DEST" ]; then
  echo "$DEST not a directory" >&2
  exit 1
fi

sudo mkdir -p $DEST
sudo rm -rf $DEST/*

sudo tar --numeric-owner -xf $ORIG/falcon-image-$MACHINE.tar.bz2 -C $DEST/
sudo cp $ORIG/uImage-$MACHINE.bin $DEST/boot/
if [ -f $ORIG/uImage-$MACHINE.dtb ]; then
    sudo cp -f $ORIG/uImage-$MACHINE.dtb $DEST/boot/
fi
if [ -f $ORIG/uImage-initramfs-$MACHINE.bin ]; then
    sudo cp -f $ORIG/uImage-initramfs-$MACHINE.bin $DEST/boot/
fi
if [ -f $ORIG/falcon-image-initramfs-$MACHINE.cpio.gz.u-boot ]; then
    sudo cp -f $ORIG/falcon-image-initramfs-$MACHINE.cpio.gz.u-boot $DEST/boot/
fi
if [ -f $ORIG/falcon-image-initramfs-$MACHINE.cpio.gz ]; then
    sudo cp -f $ORIG/falcon-image-initramfs-$MACHINE.cpio.gz $DEST/boot/
fi
if [ -f $ORIG/uEnv.txt ]; then
    sudo cp -f $ORIG/uEnv.txt $DEST/boot/
fi

sync
