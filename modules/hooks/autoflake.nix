{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "Path to autoflake binary.";
        default = null;
        defaultText = lib.literalExpression ''
          "''${tools.autoflake}/bin/autoflake"
        '';
      };

    flags =
      mkOption {
        type = types.str;
        description = "Flags passed to autoflake.";
        default = "--in-place --expand-star-imports --remove-duplicate-keys --remove-unused-variables";
      };
  };
}
