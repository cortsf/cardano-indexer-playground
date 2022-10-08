#!/usr/bin/env bash

export NETWORK=testnet
export SOCKET="./data/cardano-node-testnet/node.socket"
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export PGUSER=carp
export POSTGRES_DB=carp_testnet
export PGPASSFILE="$(realpath carp/secrets/.pgpass)"
export DATABASE_URL=postgresql://${PGUSER}:${PGPASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
export PGURI=$DATABASE_URL

./bin/carp --plan ./carp/indexer/execution_plans/default.toml

