#!/bin/bash

pushd ~/Space/PixOS/release/MacOS/ || exit
darwin-rebuild switch --flake .
popd || exit
