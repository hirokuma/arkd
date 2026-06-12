#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $(readlink -f "$0")) && pwd)
source $SCRIPT_DIR/env.sh

function generate_btc_block() {
    addr=$(nigiri rpc getnewaddress)
    nigiri rpc generatetoaddress $1 $addr
}

if [[ $# -ge 1 && "$1" == "generate" ]]; then
       blocks=1
       if [[ $# -eq 2 ]]; then
              blocks=$2
       fi
       generate_btc_block $blocks
       exit 0
fi
if [[ $# -eq 3 && "$1" == "faucet" ]]; then
       sendto=$2
       amount=$3
       nigiri faucet $sendto $amount
       exit 0
fi


if [[ $# -lt 2 ]]; then
       echo "Argument too short"
       echo "Usage: $0 <TARGET> CMD..."
       exit 1
fi

CLI="./pkg/ark-cli/build/ark-linux-amd64"
ASP_SERVER="localhost:7070"
ESPLORA_URL="http://localhost:3000"
PASSWD="dddddddd"

TARGET=$1

export ARK_WALLET_DATADIR=./data/cli/$TARGET

mkdir -p $ARK_WALLET_DATADIR
shift

if [ "$1" == "init" ]; then
       $CLI init --password $PASSWD --server-url $ASP_SERVER --explorer $ESPLORA_URL
       RECEIVE=$($CLI receive)
       BOARD_ADDR=$(echo $RECEIVE | jq -r .boarding_address)
       echo "boarding_address: $BOARD_ADDR"
       nigiri faucet $BOARD_ADDR 0.01
       generate_btc_block 1
       while :; do
              sleep 2
              balance=$($CLI balance)
              locked=$(echo $balance | jq .onchain_balance.locked_amount[0].amount)
              if [[ -n $locked && $locked != "null" && $locked != "0" ]]; then
                     echo "   Detect locked amount: $locked"
                     break
              fi
              spendable=$(echo $balance | jq .onchain_balance.spendable_amount)
              if [[ -n $spendable && $spendable != "null" && $spendable != "0" ]]; then
                     echo "   Detect spendable amount: $spendable"
                     break
              fi
              echo -n "."
       done
       echo
       $CLI settle --password $PASSWD
       $CLI balance
       $CLI vtxos
elif [ "$1" == "settle" ]; then
       $CLI settle --password $PASSWD
elif [ "$1" == "settling" ]; then
       while :; do
              $CLI settle --password $PASSWD
              sleep 2
       done
elif [ "$1" == "pay" ]; then
       addr=$(ARK_WALLET_DATADIR=./data/cli/$2 $CLI receive | jq -r .offchain_address)
       $CLI send --to $addr --amount $3 --password $PASSWD
elif [[ $# -eq 2 && "$1" == "testmode" ]]; then
       addr1=$(ARK_WALLET_DATADIR=./data/cli/$TARGET $CLI receive | jq -r .offchain_address)
       addr2=$(ARK_WALLET_DATADIR=./data/cli/$2 $CLI receive | jq -r .offchain_address)
       while :; do
              ARK_WALLET_DATADIR=./data/cli/$TARGET $CLI send --to $addr2 --amount 1000 --password $PASSWD
              sleep 5
              ARK_WALLET_DATADIR=./data/cli/$2 $CLI send --to $addr1 --amount 1000 --password $PASSWD
              sleep 5
       done
else
       $CLI $@
fi

