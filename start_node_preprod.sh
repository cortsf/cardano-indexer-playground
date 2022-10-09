#!/usr/bin/env bash
./bin/cardano-node run \
  --config ./config/cardano-node-preprod/config.json \
  --topology ./config/cardano-node-preprod/topology.json \
  --database-path ./data/cardano-node-preprod/db/ \
  --socket-path ./data/cardano-node-preprod/node.socket \
  --port 3002
