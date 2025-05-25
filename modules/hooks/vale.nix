{ lib, ... }:
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
}
