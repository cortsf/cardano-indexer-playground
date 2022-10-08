#!/usr/bin/env bash

./bin/ogmios \
    --node-socket ./data/cardano-node-mainnet/node.socket \
    --node-config ./data/cardano-node-mainnet/mainnet-config.json \


# Provides a bridge between cardano-node and WebSocket clients. Ogmios translates
# the existing CBOR-based Ouroboros mini-protocols into JSON-WSP-based protocols,
# through WebSocket channels.

# Usage: ogmios ((-v|--version) | COMMAND | --node-socket FILEPATH
#                 --node-config FILEPATH [--host IPv4] [--port TCP/PORT]
#                 [--timeout SECONDS] [--max-in-flight INT]
#                 [--log-level SEVERITY | [--log-level-health SEVERITY]
#                   [--log-level-metrics SEVERITY]
#                   [--log-level-websocket SEVERITY] [--log-level-server SEVERITY]
#                   [--log-level-options SEVERITY]])
#   Ogmios - A JSON-WSP WebSocket adaptor for cardano-node

# Available options:
#   -h,--help                Show this help text
#   -v,--version             Show the software current version and build revision.
#   --node-socket FILEPATH   Path to the node socket.
#   --node-config FILEPATH   Path to the node configuration file.
#   --host IPv4              Address to bind to. (default: "127.0.0.1")
#   --port TCP/PORT          Port to listen on. (default: 1337)
#   --timeout SECONDS        Number of seconds of inactivity after which the
#                            server should close client connections. (default: 90)
#   --max-in-flight INT      Max number of ChainSync requests which can be
#                            pipelined at once. Only applies to the chain-sync
#                            protocol. (default: 1000)
#   --log-level SEVERITY     Minimal severity of all log messages.
#                            - Debug
#                            - Info
#                            - Notice
#                            - Warning
#                            - Error
#                            Or alternatively, to turn a logger off:
#                            - Off
#   --log-level-health SEVERITY
#                            Minimal severity of health log messages.
#                            (default: Just Info)
#   --log-level-metrics SEVERITY
#                            Minimal severity of metrics log messages.
#                            (default: Just Info)
#   --log-level-websocket SEVERITY
#                            Minimal severity of websocket log messages.
#                            (default: Just Info)
#   --log-level-server SEVERITY
#                            Minimal severity of server log messages.
#                            (default: Just Info)
#   --log-level-options SEVERITY
#                            Minimal severity of options log messages.
#                            (default: Just Info)

# Available commands:
#   version                  Show the software current version and build revision.
#   health-check             Performs a health check against a running server.

# Examples:
#   Connecting to the mainnet:
#     $ ogmios --node-socket /path/to/node.socket --node-config /path/to/node/config
