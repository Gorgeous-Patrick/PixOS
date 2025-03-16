#!/bin/bash

pushd ~/Space/PixOS/ || exit
cryfs-unmount ~/Safe/
git pull
pushd applications/nix-update/ || exit
nix flake update
popd || exit

pushd applications/nvim-nix/ || exit
nix flake update
popd || exit

pushd release/MacOS/ || exit
nix flake update
popd || exit

pushd release/WSL/ || exit
nix flake update
popd || exit
popd || exit
