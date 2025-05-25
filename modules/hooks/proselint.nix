{ lib, ... }:
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
}
