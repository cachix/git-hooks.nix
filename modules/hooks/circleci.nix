{ tools, lib, pkgs, ... }:
{
  config = {
    name = "circleci";
    description = "Validate CircleCI config files.";
    package = tools.circleci-cli;
    entry = builtins.toString (pkgs.writeShellScript "precommit-circleci" ''
      set -e
      failed=false
      for file in "$@"; do
        if ! ${tools.circleci-cli}/bin/circleci config validate "$file" 2>&1
        then
          echo "Config file at $file is invalid, check the errors above."
          failed=true
        fi
      done
      if [[ $failed == "true" ]]; then
        exit 1
      fi
    '');
    files = "^.circleci/";
    types = [ "yaml" ];
  };
}