#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $(readlink -f "$0")) && pwd)
source $SCRIPT_DIR/env.sh

DATADIR="./data/fulmine"
PASSWD_FILE="./data/fulmine/password.txt"
mkdir -p $DATADIR
touch $PASSWD_FILE
docker run -d \
  --name fulmine \
  -p 7001:7001 \
  -e FULMINE_HTTP_PORT=7001 \
  -e FULMINE_ARK_SERVER="http://127.0.0.1:7070" \
  -e FULMINE_ESPLORA_URL="http://127.0.0.1:3000" \
  -e FULMINE_UNLOCKER_TYPE="file" \
  -e FULMINE_UNLOCKER_FILE_PATH="/app/password.txt" \
  -v $DATADIR:/app/data \
  -v $PASSWD_FILE:/app/password.txt \
  ghcr.io/arklabshq/fulmine:latest
