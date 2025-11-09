#!/usr/bin/env bash
# Run this script from the zmk-config directory
# Usage: ./build.sh [left] [ARGS...]

set -exo pipefail

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
  podman exec -itw /workspaces/zmk zmk-build bash -c 'test -d .west || west init -l app; west update'
fi

podman start zmk-build
podman exec -itw /workspaces/zmk zmk-build west config build.cmake-args -- "-DZMK_CONFIG=/workspaces/zmk-config/config -DZMK_EXTRA_MODULES=/workspaces/zmk-config"

if [[ $1 == "reset" ]]; then
  podman exec -itw /workspaces/zmk/app zmk-build west build -d build/settings_reset -b lotus58_ble_left -- -DSHIELD=settings_reset
  cp ../zmk/app/build/settings_reset/zephyr/zmk.uf2 zmk-settings-reset.uf2
  exit 0
fi

if [[ $1 == "left" ]] || [[ $1 == "right" ]]; then
  side=$1
  shift
fi

if [[ -n $side ]]; then
  if [[ $side = "left" ]]; then
    left=1
  fi
  podman exec -itw /workspaces/zmk/app zmk-build west build -d build/$side -b lotus58_ble_$side ${left:+-S studio-rpc-usb-uart} $@ -- -DSHIELD=nice_view_adapter -DSHIELD=nice_view
  cp ../zmk/app/build/$side/zephyr/zmk.uf2 zmk-$side.uf2
else
  podman exec -itw /workspaces/zmk/app zmk-build \
    west build -d build/left -b lotus58_ble_left -S studio-rpc-usb-uart $@ -- -DSHIELD=nice_view_adapter -DSHIELD=nice_view
  cp ../zmk/app/build/left/zephyr/zmk.uf2 zmk-left.uf2

  podman exec -itw /workspaces/zmk/app zmk-build \
    west build -d build/right -b lotus58_ble_right $@ -- -DSHIELD=nice_view_adapter -DSHIELD=nice_view
  cp ../zmk/app/build/right/zephyr/zmk.uf2 zmk-right.uf2
fi
