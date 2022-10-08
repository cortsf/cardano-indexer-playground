#!/usr/bin/env bash

root="$(realpath ./)"

cd repos/ogmios && git checkout staging && nix build && cp ./result/bin/ogmios "$root/bin/"
