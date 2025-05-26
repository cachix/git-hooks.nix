{ config, tools, lib, pkgs, ... }:
{
  config = {
    package = tools.go;
    entry =
      let
        script = pkgs.writeShellScript "precommit-gofmt" ''
          set -e
          failed=false
          for file in "$@"; do
              # redirect stderr so that violations and summaries are properly interleaved.
              if ! ${config.package}/bin/gofmt -l -w "$file" 2>&1
              then
                  failed=true
              fi
          done
          if [[ $failed == "true" ]]; then
              exit 1
          fi
        '';
      in
      builtins.toString script;
    files = "\\.go$";
  };
}
