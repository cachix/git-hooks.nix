{ writeScriptBin, terraform-docs-updater }:

writeScriptBin "terraform-docs-updater-wrapper" ''#!/usr/bin/env bash
    for arg in "$@"; do
      dirname "$arg"
    done \
    | sort \
    | uniq \
    | while read dir; do
        ${terraform-docs-updater}/bin/terraform-docs-updater "$dir"
      done
  ''
