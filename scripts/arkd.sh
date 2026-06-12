#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $(readlink -f "$0")) && pwd)
source $SCRIPT_DIR/env.sh
set -a
source envs/arkd.light.env
set +a

PASSWD_ARKD=aaaaaaaa

function generate_btc_block() {
    addr=$(nigiri rpc getnewaddress)
    nigiri rpc generatetoaddress 1 $addr
}

if [[ $# -eq 1 && "$1" == "start" ]]; then
    echo "###################"
    echo "## Build arkd, ardk-wallet ark-cli"
    echo "###################"
    make build build-wallet build-cli

    echo "###################"
    echo "## make run-wallet"
    echo "###################"
    set -a
    source envs/arkd-wallet.regtest.env
    set +a
    $ARKD_WALLET&
    sleep 10

    echo "###################"
    echo "## make run-light"
    echo "###################"
    set -a
    source envs/arkd.light.env
    set +a
    $ARKD
elif [[ $# -eq 1 && "$1" == "unlock" ]]; then
    $ARKD wallet unlock --password $PASSWD_ARKD
    exit 0
elif [[ $# -eq 1 && "$1" == "init" ]]; then
    echo ###################
    echo ## wallet create
    echo ###################
    $ARKD wallet create --password $PASSWD_ARKD
    $ARKD wallet unlock --password $PASSWD_ARKD
    sleep 3

    echo ###################
    echo ## deposit
    echo ###################
    DEP_ADDR=$($ARKD wallet address)
    echo "arkd deposit address: $DEP_ADDR"
    nigiri faucet $DEP_ADDR 10
    generate_btc_block
    $ARKD wallet balance
elif [[ $# -eq 1 && "$1" == "balance" ]]; then
    $ARKD wallet balance
elif [[ $# -ge 1 && "$1" == "generate" ]]; then
       blocks=1
       if [[ $# -eq 2 ]]; then
              blocks=$2
       fi
       addr=$(nigiri rpc getnewaddress)
       nigiri rpc generatetoaddress $blocks $addr
elif [[ $# -eq 3 && "$1" == "faucet" ]]; then
       sendto=$2
       amount=$3
       nigiri faucet $sendto $amount
else
    go run ./cmd/arkd $@
fi
