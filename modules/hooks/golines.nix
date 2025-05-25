{ tools, config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    flags = mkOption {
      type = types.str;
      description = "Flags passed to golines. See all available [here](https://github.com/segmentio/golines?tab=readme-ov-file#options)";
      default = "";
      example = "-m 120";
    };
  };

  config = {
    name = "golines";
    description = "A golang formatter that fixes long lines";
    package = tools.golines;
    entry =
      let
        script = pkgs.writeShellScript "precommit-golines" ''
          set -e
          failed=false
          for file in "$@"; do
              # redirect stderr so that violations and summaries are properly interleaved.
              if ! ${tools.golines}/bin/golines ${config.settings.flags} -w "$file" 2>&1
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
