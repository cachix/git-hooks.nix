{ writeScriptBin, cabal2nix }:

writeScriptBin "cabal2nix-dir" ''#!/usr/bin/env bash
  for cabalFile in "''$@"; do
    echo "$cabalFile"
    dir="$(dirname $cabalFile)"
    defaultFile="$dir/default.nix"
    ${cabal2nix}/bin/cabal2nix --no-hpack "$dir" > "$defaultFile"
  done
''
