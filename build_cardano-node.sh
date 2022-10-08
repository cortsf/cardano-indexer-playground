#!/usr/bin/env bash

root="$(realpath ./)"

latest_release="73960c28eae489a0c52731fff5ee47776b0db1e8"

cd ./repos/cardano-node && git checkout $latest_release && nix build .#cardano-node && cp ./result/bin/cardano-node "$root/bin/"
