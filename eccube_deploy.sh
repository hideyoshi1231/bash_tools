#!/bin/sh

cd `dirname $0`
SCRIPT_DIR=`pwd`"/"

GIT_DIR="$SCRIPT_DIR/store-server/"
SRC_DIR="$GIT_DIR/src/"
TARGET_DIR="/var/www/vhosts/dev1/"
BACKUP_DIR="$SCRIPT_DIR/backup/"
BRANCH_NAME="store_master"

if [ ! -d "$GIT_DIR.git" ]; then
echo "Please git clone here $SCRIPT_DIR"
exit 1
fi

cd $GIT_DIR
git pull origin store_master
echo "get latest source from git $BRANCH_NAME"

if [ ! -d $TARGET_DIR ]; then
echo "$TARGET_DIR does not exit."
exit 1
fi
backup_name=`date "+%Y%m%d%H%M%S"`
mkdir -p $BACKUP_DIR$backup_name
cp -r $TARGET_DIR* $BACKUP_DIR$backup_name
cp -r $SRC_DIR* $TARGET_DIR 

