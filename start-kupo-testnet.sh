#!/usr/bin/env bash

./kupo/result/bin/kupo \
  --node-socket ./data/cardano-node-testnet/node.socket \
  --node-config ./data/cardano-node-testnet/config.json \
  --workdir ./data/kupo-testnet-db \
  --since "$last_alonzo_block" \
  --match "addr_test1qp48kq895l42yxeh7mlysajeec4r7th90500vah9c3ynequn23rdjcupjftuerpd4mrz4zenvnk46uh3v0g9l7ff0k0q5s88x7"
