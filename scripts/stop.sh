#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $(readlink -f "$0")) && pwd)
source $SCRIPT_DIR/env.sh

killall arkd
killall arkd-wallet
nigiri stop

docker rm esplora
docker rm chopsticks
docker rm electrum-ws
docker rm electrs
docker rm bitcoin

docker kill nbxplorer && docker rm nbxplorer
docker kill pg && docker rm pg
docker kill fulmine && docker rm fulmine

rm -rf $HOME/.arkd $HOME/.arkd-wallet $HOME/.ark-cli ./data

echo "###################"
echo "## Done"
echo "###################"
