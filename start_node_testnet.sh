#!/usr/bin/env bash
# config:  https://hydra.iohk.io/build/13695229/download/1/index.html
# config as pointed in cardano-node repo: https://book.world.dev.cardano.org/environments.html
./bin/cardano-node run \
  --config ./data/cardano-node-testnet/config.json \
  --database-path ./data/cardano-node-testnet/db/ \
  --socket-path ./data/cardano-node-testnet/node.socket \
  --port 3001 \
  --topology ./data/cardano-node-testnet/topology.json
