{ writeScriptBin, hunspell }:

writeScriptBin "hunspell" ''#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

args=( "$@" )

misspelled_words=$(${hunspell}/bin/hunspell "''${args[@]}")

if [[ -n "$misspelled_words" ]]; then
    echo "Misspelled words:"
    echo "-----------------"
    echo "$misspelled_words"
    exit 1
fi
''
