{ lib, config, pkgs, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath =
      mkOption {
        type = types.str;
        description = "Path to the configuration TOML file.";
        # an empty string translates to use default configuration of the
        # underlying revive binary
        default = "";
      };
  };

  config = {
    package = tools.revive;
    entry =
      let
        cmdArgs =
          mkCmdArgs [
            [ true "-set_exit_status" ]
            [ (config.settings.configPath != "") "-config ${config.settings.configPath}" ]
          ];
        # revive works with both files and directories; however some lints
        # may fail (e.g. package-comment) if they run on an individual file
        # rather than a package/directory scope; given this let's get the
        # directories from each individual file.
        script = pkgs.writeShellScript "precommit-revive" ''
          set -e
          for dir in $(echo "$@" | xargs -n1 dirname | sort -u); do
            ${config.package}/bin/revive ${cmdArgs} ./"$dir"
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
