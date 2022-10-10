#!/usr/bin/env bash

./bin/kupo \
  --node-socket ./data/cardano-node-mainnet/node.socket \
  --node-config ./config/cardano-node-mainnet/mainnet-config.json \
  --workdir ./data/kupo-mainnet-db \
  --since "$last_alonzo_block" \
  --match "stake1uy6f5wg695g33ck8emlyx97vyfxyw8pmvgu5aq6hxgxscgg9s58ah"
