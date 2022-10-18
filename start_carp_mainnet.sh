#!/usr/bin/env bash

# Notes
########################################
# Run migrate_carp.sh first to create db schema!

export NETWORK=mainnet
export SOCKET="./data/cardano-node-mainnet/node.socket"
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export PGUSER=carp
export POSTGRES_DB=carp_mainnet
export PGPASSFILE="$(realpath carp/secrets/.pgpass)"
export DATABASE_URL=postgresql://${PGUSER}:${PGPASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
export PGURI=$DATABASE_URL

# ./bin/carp --start-block "18750593c67f637725a90d2161fad09f1093c6d048c43492d0f9603797ea55aa" --plan ./repos/carp/indexer/execution_plans/default.toml
./bin/carp --plan ./repos/carp/indexer/execution_plans/default.toml

