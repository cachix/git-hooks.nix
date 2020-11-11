{ writeScriptBin, purty }:

writeScriptBin "purty" ''
  #!/usr/bin/env bash
  for f in "$@"; do
    ${purty}/bin/purty $f --write
  done
''
