#!/bin/env bash
cd ~/.nix || exit 1
git commit -a -m 'nix changes (auto msg)'
nix build .#home.activationPackage --impure && \
./result/activate

