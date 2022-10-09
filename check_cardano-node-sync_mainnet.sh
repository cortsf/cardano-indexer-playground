#!/usr/bin/env bash

# This scripts shows mainnet cardano-node sync percentage

export CARDANO_NODE_SOCKET_PATH="$(realpath data/cardano-node-mainnet/node.socket)"
./bin/cardano-cli query tip --mainnet
