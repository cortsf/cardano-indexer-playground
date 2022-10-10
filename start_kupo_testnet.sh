#!/usr/bin/env bash

./bin/kupo \
  --node-socket ./data/cardano-node-testnet/node.socket \
  --node-config ./config/cardano-node-testnet/config.json \
  --workdir ./data/kupo-testnet-db \
  --since "62510369.d931221f9bc4cae34de422d9f4281a2b0344e86aac6b31eb54e2ee90f44a09b9" \
  --match "addr_test1qp48kq895l42yxeh7mlysajeec4r7th90500vah9c3ynequn23rdjcupjftuerpd4mrz4zenvnk46uh3v0g9l7ff0k0q5s88x7"
