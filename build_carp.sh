#!/usr/bin/env bash

root="$(realpath ./)"

## Cargo migrate error
## https://github.com/dcSpark/carp/commit/98cec28b5cd17cb7040461091aa2382552169e92

## Cargo authentication error
## https://sathias.gitlab.io/posts/2021/08/19/rust-cargo-resolve-authentication-issue.html

cd repos/carp/indexer && cargo build && cp ./target/debug/carp "$root/bin/"
