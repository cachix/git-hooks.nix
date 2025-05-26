{ config, lib, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath =
      mkOption {
        type = types.str;
        description = "Path to the config file.";
        default = "";
      };
    flags =
      mkOption {
        type = types.str;
        description = "Flags passed to lychee. See all available [here](https://lychee.cli.rs/#/usage/cli).";
        default = "";
      };
  };

  config = {
    package = tools.lychee;
    entry =
      let
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ (configPath != "") " --config ${configPath}" ]
            ]);
      in
      "${config.package}/bin/lychee${cmdArgs} ${config.settings.flags}";
    types = [ "text" ];
  };
}
