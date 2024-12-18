#!/bin/bash
# Run this script from the zmk-config directory
# Usage: ./build.sh [left] [ARGS...]

if ! podman container exists zmk-build; then
  podman create -it \
    --security-opt label=disable \
    --workdir /workspaces/zmk \
    -v ../zmk:/workspaces/zmk \
    -v "$PWD":/workspaces/zmk-config \
    -p 3000:3000 \
    --name zmk-build \
    zmk-build \
    /bin/bash

  podman start zmk-build
  podman exec -it zmk-build 'test -d .west || west init -l app; west update'
fi

podman start zmk-build

if [[ $1 == "left" ]]; then
  side="left"
  shift
fi

podman exec -itw /workspaces/zmk/app zmk-build \
  west build -d build/left -b lotus58_ble_left $@
cp ../zmk/app/build/left/zephyr/zmk.uf2 zmk-left.uf2

if [[ $side != "left" ]]; then
  podman exec -itw /workspaces/zmk/app zmk-build \
    west build -d build/right -b lotus58_ble_right $@
  cp ../zmk/app/build/right/zephyr/zmk.uf2 zmk-right.uf2
fi
