{ lib, writeScriptBin, tflint }:

if lib.versionAtLeast tflint.version "0.45.0"
then
  (writeScriptBin "tflint" ''
    #!/usr/bin/env bash
    ${tflint}/bin/tflint --chdir "$(dirname $1)" --filter "$(basename $1)"
  '')
else
  tflint
