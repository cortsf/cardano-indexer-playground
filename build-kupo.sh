#!/usr/bin/env bash

root="$(realpath ./)"

cd repos/kupo && make && cp ./dist/bin/kupo "$root/bin"
