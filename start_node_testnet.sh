#!/usr/bin/env bash
./bin/cardano-node run \
  --config ./config/cardano-node-testnet/config.json \
  --topology ./config/cardano-node-testnet/topology.json \
  --database-path ./data/cardano-node-testnet/db/ \
  --socket-path ./data/cardano-node-testnet/node.socket \
  --port 3002
