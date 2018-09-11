#!/bin/bash

#$1 = repository name (peregrine)
#$2 = REMOTE to CLONE -> ORIG
#$3 = repository name (external)
#$4 = REMOTE to MIRROR -> DEST
#$5 = repository name (optional)

if [ "$#" -lt 4 -o "$#" -gt 5 ]; then
    echo "How to Use:"
    echo "clone-mirror <remote orig name> <remote orig repository> <remote dest name> <remote dest repository> [<repository folder name]>"
    exit 1;
fi

# DEST === peregrine
DEST_NAME=$1
DEST_REPO=$2
# ORIG === external remote
ORIG_NAME=$3
ORIG_REPO=$4
# Repository name
REPONAME=$5

git ls-remote $DEST_REPO >> /dev/null
if [ $? -ne 0 ]; then
    echo "Abort! Destine mirror [$DEST_REPO] not exists."
    exit 1;
fi

git ls-remote $ORIG_REPO >> /dev/null
if [ $? -ne 0 ]; then
    echo "Abort! Origin clone [$ORIG_REPO] not exists."
    exit 1;
fi

if [ -z $REPONAME ]; then
    DEST_BASE=$(basename "$DEST_REPO")
else
    DEST_BASE=$REPONAME
fi

if [ -d $DEST_BASE ]; then
    cd $DEST_BASE
else
    echo "Init local repository"
    git clone $DEST_REPO $REPONAME

    cd $DEST_BASE

    echo "Add remote upstream [$ORIG_NAME]"
    git remote add $ORIG_NAME $ORIG_REPO
fi

git fetch --all
LST_REMOTE_BRANCHS=`git for-each-ref --shell --format='%(refname)' refs/remotes/$ORIG_NAME`
LEN=$(( 15 + ${#ORIG_NAME} ))
for branch in $LST_REMOTE_BRANCHS; do
    branch_name=`echo $branch | tr -d \' | cut -c$LEN-`
    echo $branch_name
    git show-ref refs/heads/$branch_name >> /dev/null
    git stash >> /dev/null
    git stash drop >> /dev/null
    git checkout -B ${branch_name} $ORIG_NAME/${branch_name}
    git push --set-upstream -f $DEST_NAME refs/heads/${branch_name}
    git push --tags
done
