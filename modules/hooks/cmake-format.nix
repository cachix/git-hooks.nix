{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath = mkOption {
      type = types.str;
      description = "Path to the configuration file (.json,.python,.yaml)";
      default = "";
      example = ".cmake-format.json";
    };
  };
}
