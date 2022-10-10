#!/usr/bin/env bash

./bin/kupo \
  --node-socket ./data/cardano-node-mainnet/node.socket \
  --node-config ./config/cardano-node-mainnet/mainnet-config.json \
  --workdir ./data/kupo-mainnet-db \
  --since "39916796.e72579ff89dc9ed325b723a33624b596c08141c7bd573ecfff56a1f7229e4d09" \
  --match "stake1uy6f5wg695g33ck8emlyx97vyfxyw8pmvgu5aq6hxgxscgg9s58ah"
