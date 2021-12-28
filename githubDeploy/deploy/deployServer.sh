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
CERT_FILE=`cat ./.cert`
rm -f ./.cert
WORKING_DIR=$(pwd)
OUTPUT_FILE="${WORKING_DIR}/server_debug.txt"
FINISHED="${WORKING_DIR}/server_finished.txt"
rm -f FINISHED

echo i"=======================================" > $OUTPUT_FILE
echo "** GITHUB Server Deployment Script **" >> $OUTPUT_FILE
echo "=======================================" >> $OUTPUT_FILE

# if a pid file exists, kill all its descendants
if [ -f "./deployServer.pid" ]; then
  echo "A deployment is already in progress, stopping it..." >> $OUTPUT_FILE
  kill $(ps -o pid= --ppid `cat ./deployServer.pid`) >> $OUTPUT_FILE
  kill `cat ./deployServer.pid` >> $OUTPUT_FILE
fi

# create a pid file
echo "===============================" >> $OUTPUT_FILE
echo "** Github Clone initiated... **" >> $OUTPUT_FILE
echo "===============================" >> $OUTPUT_FILE
echo $$ > ./deployServer.pid

# remove previous build
rm -rf ./deployServer_temp* >> $OUTPUT_FILE
pid=`cat ./deployServer.pid`
DEPLOY_DIRECTORY="./deployServer_temp_${pid}"
git clone -b $2 $SOURCE_REPO $DEPLOY_DIRECTORY >> $OUTPUT_FILE

# create a pid file
echo "================================================" >> $OUTPUT_FILE
echo "** Getting certs and environment variables... **" >> $OUTPUT_FILE
echo "================================================" >> $OUTPUT_FILE
pushd $CERT_FILE
./retrieve-cert.sh >> $OUTPUT_FILE
popd
cd $DEPLOY_DIRECTORY/server
mkdir cert >> $OUTPUT_FILE
cp $CERT_FILE/*.pem ./cert/ >> $OUTPUT_FILE
cp $CERT_FILE/.env . >> $OUTPUT_FILE
rm -rf .gitignore >> $OUTPUT_FILE

echo "========================================" >> $OUTPUT_FILE
echo "** Copying and installing packages... **" >> $OUTPUT_FILE
echo "========================================" >> $OUTPUT_FILE
# create new build
pm2 stop all >> $OUTPUT_FILE
rm -rf $TARGET_FOLDER >> $OUTPUT_FILE
cd ..
mv -f server $TARGET_FOLDER >> $OUTPUT_FILE
pushd $TARGET_FOLDER >> $OUTPUT_FILE
npm ci
ln -s -d /usr/local/nginx/html/images images >> $OUTPUT_FILE
pm2 start all >> $OUTPUT_FILE

# remove files after finish
popd
cd ..
rm -rf ./deployServer_temp* >> $OUTPUT_FILE
rm -f ./deployServer.pid >> $OUTPUT_FILE
rm -f ./.repo
rm -f ./.cert

echo "=====================" >> $OUTPUT_FILE
echo "** Server Deployed **" >> $OUTPUT_FILE
echo "=====================" >> $OUTPUT_FILE
