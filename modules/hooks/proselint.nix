{ lib, config, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    config =
      mkOption {
        type = types.str;
        description = "Multiline-string configuration passed as config file.";
        default = "";
        example = ''
          {
            "checks": {
              "typography.diacritical_marks": false
            }
          }
        '';
      };
    configPath =
      mkOption {
        type = types.str;
        description = "Path to the config file.";
        default = "";
      };
    flags =
      mkOption {
        type = types.str;
        description = "Flags passed to proselint.";
        default = "";
      };
  };

  config = {
    name = "proselint";
    description = "A linter for prose.";
    types = [ "text" ];
    package = tools.proselint;
    entry =
      let
        configFile = builtins.toFile "proselint-config.json" "${config.settings.config}";
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ (configPath != "") " --config ${configPath}" ]
              [ (config != "" && configPath == "") " --config ${configFile}" ]
            ]);
      in
      "${config.package}/bin/proselint${cmdArgs} ${config.settings.flags}";
  };
}
