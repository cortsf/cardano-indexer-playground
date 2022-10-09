#!/usr/bin/env bash

# This scripts shows testnet cardano-node sync percentage

export CARDANO_NODE_SOCKET_PATH="$(realpath data/cardano-node-testnet/node.socket)"
./bin/cardano-cli query tip --testnet-magic 1097911063
