{ writeScriptBin, hpack }:

writeScriptBin "hpack-dir" ''#!/usr/bin/env bash
  if [ "$1" == "--silent" ]; then
    flag=$1
  fi
  for arg in "''${@:2}"; do
    dirname "$arg"
  done \
    | sort \
    | uniq \
    | while read dir; do
        if [ -f "$dir/package.yaml" ]; then
          ${hpack}/bin/hpack --force $flag "$dir/package.yaml"
        fi
      done
''
