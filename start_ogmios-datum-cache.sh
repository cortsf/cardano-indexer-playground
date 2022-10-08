#!/usr/bin/env bash

# ODC needs a running ogmios instance to work. Start it with ./start_ogmios_<network>.sh

./bin/ogmios-datum-cache \
    --db-port 5432 \
    --db-host localhost \
    --db-user odc \
    --db-password odc \
    --db-name ogmios_datum_cache \
    --server-port 8027 \
    --server-api "usr:pwd" \
    --ogmios-address "localhost" \
    --ogmios-port 1337 \


# Usage: ogmios-datum-cache (--db-port PORT --db-host HOST_NAME
#                             --db-user USER_NAME [--db-password PASSWORD]
#                             --db-name DB_NAME |
#                             --db-connection POSTGRES_LIBPQ_CONNECTION_STRING)
#                           --server-port PORT
#                           --server-api SERVER_CONTROL_API_TOKEN
#                           --ogmios-address ADDRESS --ogmios-port PORT
#                           [--block-slot INT --block-hash HASH | --from-origin |
#                             --from-tip] [--block-filter FILTER] [--use-latest]
#                           [--queue-size NATURAL] [--log-level LOG_LEVEL]
#                           [--old-ogmios]
