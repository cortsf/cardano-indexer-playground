#!/usr/bin/env bash
./bin/cardano-node run \
  --config ./config/cardano-node-mainnet/mainnet-config.json \
  --topology ./config/cardano-node-mainnet/mainnet-topology.json \
  --database-path ./data/cardano-node-mainnet/db/ \
  --socket-path ./data/cardano-node-mainnet/node.socket \
  --port 3001
