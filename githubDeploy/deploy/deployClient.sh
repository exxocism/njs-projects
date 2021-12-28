#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#move to destination location & store Environment variables
cd $1
TARGET_FOLDER=`cat *`
rm -rf *
cd ..
SOURCE_REPO=`cat ./.repo`
rm -f ./.repo
WORKING_DIR=$(pwd)
OUTPUT_FILE="${WORKING_DIR}/client_debug.txt"
FINISHED="${WORKING_DIR}/client_finished.txt"
rm -f FINISHED


echo "=======================================" > $OUTPUT_FILE
echo "** GITHUB Client Deployment Script **" >> $OUTPUT_FILE
echo "=======================================" >> $OUTPUT_FILE

# if a pid file exists, kill all its descendants
if [ -f "./deployClient.pid" ]; then
  echo "A deployment is already in progress, stopping it..." >> $OUTPUT_FILE
  kill $(ps -o pid= --ppid `cat ./deployClient.pid`) >> $OUTPUT_FILE
  kill `cat ./deployClient.pid` >> $OUTPUT_FILE
fi

# create a pid file
echo "===============================" >> $OUTPUT_FILE
echo "** Github Clone initiated... **" >> $OUTPUT_FILE
echo "===============================" >> $OUTPUT_FILE
echo $$ > ./deployClient.pid

# remove previous build
rm -rf ./deployClient_temp* >> $OUTPUT_FILE
pid=`cat ./deployClient.pid`
DEPLOY_DIRECTORY="./deployClient_temp_${pid}"
git clone -b $2 $SOURCE_REPO $DEPLOY_DIRECTORY >> $OUTPUT_FILE

echo "=========================" >> $OUTPUT_FILE
echo "** Installing packages... **" >> $OUTPUT_FILE
echo "=========================" >> $OUTPUT_FILE

# create new build
cd $DEPLOY_DIRECTORY/client
npm ci

echo "=========================" >> $OUTPUT_FILE
echo "** Building packages... **" >> $OUTPUT_FILE
echo "=========================" >> $OUTPUT_FILE
npm run build
rm -rf $TARGET_FOLDER/static >> $OUTPUT_FILE
mv -f build/* $TARGET_FOLDER >> $OUTPUT_FILE

# remove files after finish
cd ../..
rm -rf ./deployClient_temp* >> $OUTPUT_FILE
rm -f ./deployClient.pid >> $OUTPUT_FILE
rm -f ./.repo

echo "=====================" >> $OUTPUT_FILE
echo "** Client Deployed **" >> $OUTPUT_FILE
echo "=====================" >> $OUTPUT_FILE
