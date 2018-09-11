#!/bin/sh
# Convert git log to asciidoc ChangeLog file.
# (C) Deen Seth

rm release-notes.log
Date=$1
ListName='"meta-falcon"'

for i in $ListName; do
    DIR=`echo "$i" | tr -d '"'`
    echo $DIR
    cd $DIR
    git checkout master
    git pull origin master
    echo $DIR >> ../release-notes.log
    echo $DIR":"`git rev-parse HEAD` >> ../release-notes.log
    git log --reverse --date=format:%d/%m/%Y --pretty=tformat:"%ad - %s" --after=$Date >> ../release-notes.log
    echo ""
    cd ..
done

cd linux
echo "LINUX"
echo "LINUX" >> ../release-notes.log
Linux='"linux-yocto"'
for i in $Linux; do
    LNX=`echo "$i" | tr -d '"'`
    echo $LNX
    git checkout $LNX
    git pull origin #LNX
    echo $LNX":"`git rev-parse HEAD` >> ../release-notes.log
    git log --reverse --date=format:%d/%m/%Y --pretty=tformat:"%ad - %s" --after=$Date >> ../release-notes.log
    echo ""
done
cd ..
cd u-boot
echo "U-Boot"
echo "U-Boot" >> ../release-notes.log
Uboot='"u-boot"'
for i in $Uboot; do
    BOOT=`echo "$i" | tr -d '"'`
    echo $BOOT
    git checkout $BOOT
    git pull origin #BOOT
    echo $BOOT":"`git rev-parse HEAD` >> ../release-notes.log
    git log --reverse --date=format:%d/%m/%Y --pretty=tformat:"%ad - %s" --after=$Date >> ../release-notes.log
    echo ""
done
cd ..
