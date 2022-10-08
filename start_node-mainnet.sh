#!/usr/bin/env bash
# config:  https://hydra.iohk.io/build/13695229/download/1/index.html
# config as pointed in cardano-node repo: https://book.world.dev.cardano.org/environments.html
./cardano-node run \
  --config ./cardano-node-mainnet/mainnet-config.json \
  --database-path ./cardano-node-mainnet/db/ \
  --socket-path ./cardano-node-mainnet/node.socket \
  --port 3001 \
  --topology ./cardano-node-mainnet/mainnet-topology.json
