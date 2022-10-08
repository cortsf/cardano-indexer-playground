#!/usr/bin/env bash
# config:  https://hydra.iohk.io/build/13695229/download/1/index.html
# config as pointer in cardano-node repo: https://book.world.dev.cardano.org/environments.html
./cardano-node run \
  --config ./cardano-node-testnet/config.json \
  --database-path ./cardano-node-testnet/db/ \
  --socket-path ./cardano-node-testnet/node.socket \
  --port 3001 \
  --topology ./cardano-node-testnet/topology.json
