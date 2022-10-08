#!/usr/bin/env bash

root="$(realpath ./)"

cd repos/carp/indexer && cargo build && cp ./target/debug/carp "$root/bin/"
