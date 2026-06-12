#!/bin/bash -e

SCRIPT_DIR=$(cd $(dirname $(readlink -f "$0")) && pwd)
source $SCRIPT_DIR/env.sh

echo "###################"
echo "## Start Nigiri"
echo "###################"
mkdir -p $NIGIRI_DATADIR
nigiri start
sleep 3

echo "###################"
echo "## Start PostgreSQL and NBXplorer"
echo "###################"
docker compose -f docker-compose.regtest.yml up -d pg nbxplorer
sleep 10
