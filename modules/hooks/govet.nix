{ config, tools, lib, pkgs, ... }:
{
  config = {
    package = tools.go;
    entry =
      let
        # go vet requires package (directory) names as inputs.
        script = pkgs.writeShellScript "precommit-govet" ''
          set -e
          for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
            ${config.package}/bin/go vet -C ./"$dir"
          done
        '';
      in
      builtins.toString script;
    # to avoid multiple invocations of the same directory input, provide
    # all file names in a single run.
    require_serial = true;
    files = "\.go$";
  };
}
