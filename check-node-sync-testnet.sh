#!/usr/bin/env bash

# This scripts shows testnet cardano-node sync percentage

export CARDANO_NODE_SOCKET_PATH=/home/fcortesi/index/cardano-node-testnet/node.socket
./cardano-cli query tip --testnet-magic 1097911063
