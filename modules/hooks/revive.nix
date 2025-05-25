{ lib, ... }:
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
}
