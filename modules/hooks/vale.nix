{ lib, tools, config, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configuration =
      mkOption {
        type = types.str;
        description = "Multiline-string configuration passed as config file.";
        default = "";
        example = ''
          MinAlertLevel = suggestion
          [*]
          BasedOnStyles = Vale
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
        description = "Flags passed to vale.";
        default = "";
      };
  };

  config = {
    name = "vale";
    description = "A markup-aware linter for prose built with speed and extensibility in mind.";
    package = tools.vale;
    entry =
      let
        # TODO: was .vale.ini, threw error in Nix
        configFile = builtins.toFile "vale.ini" "${config.settings.configuration}";
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ (configPath != "") " --config ${configPath}" ]
              [ (configuration != "" && configPath == "") " --config ${configFile}" ]
            ]);
      in
      "${config.package}/bin/vale${cmdArgs} ${config.settings.flags}";
    types = [ "text" ];
  };
}
