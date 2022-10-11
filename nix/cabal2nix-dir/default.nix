{ writeScriptBin, cabal2nix }:

writeScriptBin "cabal2nix-dir" ''#!/usr/bin/env bash
  projectdir="$(pwd)"
  for cabalFile in "''$@"; do
    echo "$cabalFile"
    dir="$(dirname $cabalFile)"
    cd "$projectdir/$dir"
    ${cabal2nix}/bin/cabal2nix --no-hpack . > default.nix
  done
''
