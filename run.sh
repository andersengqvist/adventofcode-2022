#!/bin/bash

# Usage:
# ./run.sh day1

# https://hub.docker.com/_/elixir
docker run -it --rm --name aoc2022 \
    --volume="$PWD":/usr/src/aoc2022 \
    --workdir=/usr/src/aoc2022 \
    elixir elixir "$1".exs
