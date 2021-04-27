{ writeScriptBin, hpack }:

writeScriptBin "hpack-dir" ''#!/usr/bin/env bash
  for arg in "$@"; do
    dirname "$arg"
  done \
    | sort \
    | uniq \
    | while read dir; do
        local packageyaml="$dir/package.yaml"
        if [ -f "$packageyaml" ]; then
          ${hpack}/bin/hpack --force "$packageyaml"
        fi
      done
''
