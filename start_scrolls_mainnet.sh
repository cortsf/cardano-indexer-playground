#!/usr/bin/env bash

RUST_LOG=info ./bin/scrolls daemon --console plain --config ./config/scrolls_mainnet.toml
# RUST_LOG=info ./bin/scrolls daemon --console plain --config ./config/scrolls_mainnet_RANDOM.toml # WORKING DEMO USING RECENT DATA.
# RUST_LOG=info ./bin/scrolls daemon --console plain --config ./config/scrolls_mainnet_smolStaking.toml # WORKING DEMO USING SMOLSTAKING ADDRESS.
