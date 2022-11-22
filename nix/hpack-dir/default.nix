{ writeScriptBin, hpack }:

writeScriptBin "hpack-dir" ''#!/usr/bin/env bash
  if [ "$1" == "--silent" ]; then
    flag=$1
  fi

  find . -type f -name 'package.yaml' -exec hpack --force $flag {} \;
''
