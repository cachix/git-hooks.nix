{ tools, lib, config, pkgs, ... }:
{
  config = {
    name = "staticcheck";
    description = "State of the art linter for the Go programming language";
    package = tools.go-tools;
    # staticheck works with directories.
    entry =
      let
        script = pkgs.writeShellScript "precommit-staticcheck" ''
          err=0
          for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
            ${config.package}/bin/staticcheck ./"$dir"
            code="$?"
            if [[ "$err" -eq 0 ]]; then
                err="$code"
            fi
          done
          exit $err
        '';
      in
      builtins.toString script;
    files = "\\.go$";
    # to avoid multiple invocations of the same directory input, provide
    # all file names in a single run.
    require_serial = true;
  };
}
