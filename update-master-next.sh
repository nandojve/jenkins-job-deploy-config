#!/bin/bash

#$1 = repository name

PWD=`pwd`
REPOSITORY=$1

if test "$#" -ne 1; then
    echo "How to Use:"
    echo "update-master-next <repository name>"
    exit 1;
fi

cd $REPOSITORY

git checkout master
git pull origin master-next
git rebase master-next
git push
git log -1
