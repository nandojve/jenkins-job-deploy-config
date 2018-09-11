#!/bin/bash

TRACKED_FILES="repo diff"
UNTRACKED_FILES=( `repo forall -p -c git ls-files -o --exclude-standard --full-name` )
BACKUP_DIR="backup"
PROJECT_DIR=""

mkdir -p $BACKUP_DIR

`$TRACKED_FILES > $BACKUP_DIR/repo.diff`

for (( i=0; i<"${#UNTRACKED_FILES[@]}" ; i++ ))
do
    f=${UNTRACKED_FILES[$i]}
    if [[ $f == project* ]]; then
        i=$i+1
        PROJECT_DIR=${UNTRACKED_FILES[$i]}
        echo "Tracking $PROJECT_DIR"
        continue
    fi
    echo "    Copy $f"
    mkdir -p $BACKUP_DIR/$PROJECT_DIR$(dirname $f)
    cp $PROJECT_DIR$f $BACKUP_DIR/$PROJECT_DIR$f
done

cd $BACKUP_DIR
tar -cf ../backup.tar.bz2 .
cd ..
rm -rf $BACKUP_DIR
