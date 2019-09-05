{ writeScriptBin, terraform }:

writeScriptBin "terraform-fmt" ''#!/usr/bin/env bash
  for arg in "$@"; do
    dirname "$arg"
  done \
    | sort \
    | uniq \
    | while read dir; do
        ${terraform}/bin/terraform fmt "$dir"
      done
''
