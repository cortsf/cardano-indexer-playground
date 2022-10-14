#!/usr/bin/env bash

root="$(realpath ./)"

## Cargo authentication error
## https://sathias.gitlab.io/posts/2021/08/19/rust-cargo-resolve-authentication-issue.html

cd repos/oura && cargo build && cp ./target/debug/oura "$root/bin/"
