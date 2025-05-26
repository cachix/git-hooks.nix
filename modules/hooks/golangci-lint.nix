{ config, tools, lib, pkgs, ... }:
{
  config = {
    name = "golangci-lint";
    description = "Fast linters runner for Go.";
    package = tools.golangci-lint;
    entry =
      let
        script = pkgs.writeShellScript "precommit-golangci-lint" ''
          set -e
          for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
            ${config.package}/bin/golangci-lint run ./"$dir"
          done
        '';
      in
      builtins.toString script;
    files = "\\.go$";
    # to avoid multiple invocations of the same directory input, provide
    # all file names in a single run.
    require_serial = true;
  };
}
