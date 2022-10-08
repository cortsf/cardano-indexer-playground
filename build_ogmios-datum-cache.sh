#!/usr/bin/env bash

root="$(realpath ./)"

cd repos/ogmios-datum-cache && nix build && cp ./result/bin/ogmios-datum-cache "$root/bin/"