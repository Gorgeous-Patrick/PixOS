#!/bin/bash

pushd ~/Space/PixOS/release/MacOS/ || exit
pushd applications/nix-update/ || exit
nix flake update
popd || exit

pushd applications/nvim-nix/ || exit
nix flake update
popd || exit

pushd release/MacOS/ || exit
nix flake update
popd || exit
popd || exit
