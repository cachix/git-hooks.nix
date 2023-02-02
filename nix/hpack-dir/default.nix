{ writeScriptBin, hpack }:

writeScriptBin "hpack-dir" ''#!/usr/bin/env bash
  set -e
  ##  ^^
  ## The `-e` flag changes the behaviour of Shell so that the first top-level
  ## failure of a command causes failure of the whole script.

  if [ "$1" == "--silent" ]; then
    flag=$1
  fi

  find . -type f -name package.yaml | while read -r file; do
    ${hpack}/bin/hpack --force $flag "$file"
    ##           ^^^^^
    ## The `find | while` pattern has for upside that it puts this `hpack` call
    ## at toplevel. In conjunction with the `-e` flag above, this ensures that
    ## a failure of `hpack` will lead to a failure of the pre-commit hook.
  done
''
