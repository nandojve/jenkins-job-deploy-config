#!/bin/bash

#$1 = [sync | update | build | bitbake]
#S2 = STRATEGY
CMD=$1
STRATEGY=$2

# build cmd:
#$3 = WORKSPACE
#$4 = DISTRO
#$5 = MACHINE
#$6 = IMAGE_CMD [image | sdk]
#$7 = IMAGE_NAME
#$8 = BUILD_NUMBER
WORKSPACE=$3
DISTRO=$4
MACHINE=$5
IMAGE_CMD=$6
IMAGE_NAME=$7
BUILD_NUMBER=$8

update_local_conf () {
    MODE=$1

    cp $LOCAL_FACTORY $LOCAL_CONF

    sed -i -e "s,@DEPLOY@,$DEPLOY,g" $LOCAL_CONF
    sed -i -e "s,@DISTRO@,$DISTRO,g" $LOCAL_CONF
    sed -i -e "s,@MACHINE@,$MACHINE,g" $LOCAL_CONF
    sed -i -e "s,@GERRIT_STRATEGY@,$STRATEGY,g" $LOCAL_CONF
    sed -i -e "s,@GERRIT_CONFDIR@,$LOCAL_FACTORY_DIR,g" $LOCAL_CONF
    sed -i -e "s,@GERRIT_MODE@,$MODE,g" $LOCAL_CONF
    sed -i -e "s,@BUILD_NUMBER@,$BUILD_NUMBER,g" $LOCAL_CONF
#    if [ $IMAGE_CMD == "review" ] ; then
#        sed -i -e "s,@BUILDHISTORY@,0,g" $LOCAL_CONF
#    else
#        sed -i -e "s,@BUILDHISTORY@,1,g" $LOCAL_CONF
#    fi
#
#    if [ $IMAGE_CMD == "sdk" -o $IMAGE_CMD == "review" ] ; then
#        echo 'ERROR_QA_remove = " version-going-backwards"' >> $LOCAL_CONF
#        echo 'WARN_QA_append = " version-going-backwards"' >> $LOCAL_CONF
#    fi
}

set -e

export PATH=$PATH:~/bin

if [ $CMD == "sync" ] ; then
    rm -rf sources/meta-falcon

    repo sync
    exit 0
elif [ $CMD == "update" ] ; then
    ./update_recipe.py $STRATEGY
    exit 0
elif [ $CMD != "build" -a $CMD != "bitbake" ] ; then
    echo "The CMD [$CMD] is invalid. Abort!"
    exit 1
fi

LOCAL_CONF="./conf/local.conf"
GERRIT_CONF="./conf/gerrit-patchset.conf"
LOCAL_FACTORY_DIR="../sources/conf/jenkins/job-deploy-config"
LOCAL_FACTORY="$LOCAL_FACTORY_DIR/$IMAGE_NAME.$STRATEGY.local.conf.template"

# Now, can be defined at environment the variable and if not default value will be used.
: ${GERRIT_EVENT:=""}
: ${GERRIT_HOST:=""}
: ${GERRIT_PROJECT:=""}
: ${GERRIT_BRANCH:=""}
: ${GERRIT_PATCHSET:=""}
: ${GERRIT_MODE:="0"}

DEPLOY=$YOCTO_DEPLOY_DIR
MACHINE=$MACHINE source setup-environment $STRATEGY-$GERRIT_MODE

if [[ -z "${GERRIT_EVENT// }" ]] ; then
    # remove GERRIT_CONF file if no GERRIT_EVENT occurred
    if [ -f $GERRIT_CONF ]; then
        rm $GERRIT_CONF
    fi

    # Sanity check, mas mode is 2 if no GERRIT_EVENT specified
    if [ "$GERRIT_MODE" -gt "3" ] ; then
        GERRIT_MODE="2"
    fi
else
    # add/replace GERRIT_CONF file with patchset from GERRIT_EVENT
    echo "GERRIT_EVENT = \"$GERRIT_EVENT\""       >  $GERRIT_CONF
    echo "GERRIT_HOST = \"$GERRIT_HOST\""         >> $GERRIT_CONF
    echo "GERRIT_PROJECT = \"$GERRIT_PROJECT\""   >> $GERRIT_CONF
    echo "GERRIT_BRANCH = \"$GERRIT_BRANCH\""     >> $GERRIT_CONF
    echo "GERRIT_PATCHSET = \"$GERRIT_PATCHSET\"" >> $GERRIT_CONF
fi

update_local_conf "0"

if [ $CMD == "build"  ] ; then
    if [ $IMAGE_CMD == "image" -o $IMAGE_CMD == "review" ] ; then
        if [ $MACHINE == "comex" ] ; then
            MACHINE_IMAGE_DEP="rmc-db systemd-boot intel-microcode"
        else
            MACHINE_IMAGE_DEP="virtual/bootloader"
        fi

        bitbake -c clean -f virtual/kernel $MACHINE_IMAGE_DEP $IMAGE_NAME $IMAGE_NAME-initramfs
        rm -rf $DEPLOY/images/$MACHINE
        update_local_conf $GERRIT_MODE
        bitbake -k $IMAGE_NAME
    elif [ $IMAGE_CMD == "sdk" ] ; then
        bitbake -c clean -f $IMAGE_NAME-sdk
        update_local_conf $GERRIT_MODE
        bitbake -k $IMAGE_NAME-sdk -c populate_sdk
    else
        echo "The IMAGE_CMD [$IMAGE_CMD] is invalid. Abort!"
        exit 1
    fi
else
    $IMAGE_CMD
fi
