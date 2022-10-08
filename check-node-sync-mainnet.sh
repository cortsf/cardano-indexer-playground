#!/usr/bin/env bash

#  This scripts shows mainnet cardano-node sync percentage

export CARDANO_NODE_SOCKET_PATH=/home/fcortesi/index/cardano-node-mainnet/node.socket
./cardano-cli query tip --mainnet
